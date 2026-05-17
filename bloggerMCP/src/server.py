#!/usr/bin/env python3
"""
Blogger MCP Server
Generic MCP server using Streamable HTTP transport.
Compatible with VS Code, Claude Desktop, n8n, and all MCP clients.
"""

import os
import json
import logging
from pathlib import Path

# Allow OAuth over HTTP for localhost (development only)
os.environ['OAUTHLIB_INSECURE_TRANSPORT'] = '1'

from mcp.server import FastMCP

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# OAuth2 Scopes
SCOPES = ['https://www.googleapis.com/auth/blogger']

# File paths
CREDENTIALS_PATH = os.getenv('GOOGLE_APPLICATION_CREDENTIALS', '/app/credentials.json')
TOKEN_PATH = os.getenv('BLOGGER_TOKEN_PATH', '/app/token.json')
PORT = int(os.getenv('PORT', 8081))

# Create MCP server with streamable HTTP configuration
mcp = FastMCP(
    name="blogger-mcp-server",
    host="0.0.0.0",
    port=PORT,
    streamable_http_path="/mcp",
    json_response=True,
    stateless_http=True
)


class BloggerService:
    """Google Blogger API service wrapper"""
    
    def __init__(self):
        self.creds: Credentials | None = None
        self.service = None
    
    def init_service(self):
        """Initialize Google Blogger API service"""
        if not Path(CREDENTIALS_PATH).exists():
            raise FileNotFoundError(f"Credentials file not found: {CREDENTIALS_PATH}")
        
        # Load existing token if available
        if Path(TOKEN_PATH).exists():
            try:
                self.creds = Credentials.from_authorized_user_file(TOKEN_PATH, SCOPES)
                logger.info("Loaded credentials from token file")
            except Exception as e:
                logger.warning(f"Failed to load token: {e}")
                self.creds = None
        
        # Refresh token if expired
        if self.creds:
            if self.creds.expired and self.creds.refresh_token:
                try:
                    logger.info("Refreshing expired access token...")
                    self.creds.refresh(Request())
                    self.save_token()
                    logger.info("Access token refreshed successfully")
                except Exception as e:
                    logger.error(f"Failed to refresh token: {e}")
                    raise ValueError("Token refresh failed. Re-authentication required. Use blogger_auth_get_url.")
            elif self.creds.expired and not self.creds.refresh_token:
                raise ValueError("Access token expired and no refresh token available. Re-authenticate with blogger_auth_get_url.")
        
        if not self.creds or not self.creds.valid:
            raise ValueError("Not authenticated. Use blogger_auth_get_url first.")
        
        self.service = build('blogger', 'v3', credentials=self.creds)
        logger.info("Blogger service initialized successfully")
    
    def save_token(self):
        """Save credentials token to file"""
        if self.creds:
            with open(TOKEN_PATH, 'w') as token_file:
                token_file.write(self.creds.to_json())


# Global blogger service instance
blogger = BloggerService()


@mcp.tool()
def blogger_auth_get_url() -> str:
    """Get OAuth2 authorization URL for first-time setup"""
    flow = InstalledAppFlow.from_client_secrets_file(CREDENTIALS_PATH, SCOPES)
    flow.redirect_uri = 'http://localhost'
    
    # IMPORTANT: prompt='consent' ensures refresh_token is always returned
    auth_url, _ = flow.authorization_url(
        prompt='consent',      # Force consent screen to get refresh token
        access_type='offline'  # Request offline access for refresh token
    )
    
    return f"""Open this URL in your browser:
{auth_url}

The browser will redirect to localhost. Copy the FULL URL from the browser address bar and use blogger_auth_complete_flow with that URL.

IMPORTANT: This will generate a refresh token that allows automatic token renewal without re-authentication."""


@mcp.tool()
def blogger_auth_complete_flow(redirect_url: str) -> str:
    """Complete OAuth2 authorization with redirect URL from browser
    
    Args:
        redirect_url: The full URL from browser after authorization (e.g., http://localhost/?code=...&scope=...)
    """
    if not redirect_url:
        raise ValueError("Redirect URL is required")
    
    flow = InstalledAppFlow.from_client_secrets_file(CREDENTIALS_PATH, SCOPES)
    flow.redirect_uri = 'http://localhost'
    # Extract authorization response from URL
    flow.fetch_token(authorization_response=redirect_url)
    
    blogger.creds = flow.credentials
    blogger.save_token()
    
    return "Authorization successful! Token saved. You can now use other Blogger tools."


@mcp.tool()
def blogger_list_blogs() -> str:
    """List all blogs for the authenticated user"""
    if not blogger.service:
        blogger.init_service()
    
    try:
        result = blogger.service.blogs().listByUser(userId='self').execute()
        blogs = result.get('items', [])
        
        blog_list = []
        for blog in blogs:
            blog_list.append({
                'id': blog['id'],
                'name': blog['name'],
                'url': blog['url'],
                'description': blog.get('description', ''),
                'posts': blog.get('posts', {}).get('totalItems', 0)
            })
        
        return json.dumps(blog_list, indent=2)
    except HttpError as e:
        raise Exception(f"Blogger API error: {e.resp.status} - {e.error_details}")


@mcp.tool()
def blogger_list_posts(
    blogId: str,
    status: list[str] | None = None,
    maxResults: int = 10,
    fetchBodies: bool = False
) -> str:
    """List posts from a blog
    
    Args:
        blogId: The ID of the blog
        status: Filter by post status (LIVE, DRAFT, SCHEDULED)
        maxResults: Maximum number of posts to return (default: 10, max: 500)
        fetchBodies: Whether to fetch post content (default: false)
    """
    if not blogger.service:
        blogger.init_service()
    
    try:
        params = {
            'blogId': blogId,
            'maxResults': min(maxResults, 500),
            'fetchBodies': fetchBodies
        }
        
        if status:
            params['status'] = status
        
        result = blogger.service.posts().list(**params).execute()
        posts = result.get('items', [])
        
        post_list = []
        for post in posts:
            post_data = {
                'id': post['id'],
                'title': post['title'],
                'url': post['url'],
                'published': post.get('published', ''),
                'updated': post.get('updated', ''),
                'status': post.get('status', ''),
                'labels': post.get('labels', [])
            }
            
            if fetchBodies:
                post_data['content'] = post.get('content', '')
            
            post_list.append(post_data)
        
        return json.dumps(post_list, indent=2)
    except HttpError as e:
        raise Exception(f"Blogger API error: {e.resp.status} - {e.error_details}")


@mcp.tool()
def blogger_get_post(blogId: str, postId: str) -> str:
    """Get a specific post by ID with full content and metadata
    
    Args:
        blogId: The ID of the blog
        postId: The ID of the post
    """
    if not blogger.service:
        blogger.init_service()
    
    try:
        post = blogger.service.posts().get(blogId=blogId, postId=postId).execute()
        
        post_data = {
            'id': post['id'],
            'blogId': post['blog']['id'],
            'title': post['title'],
            'content': post.get('content', ''),
            'url': post['url'],
            'published': post.get('published', ''),
            'updated': post.get('updated', ''),
            'status': post.get('status', ''),
            'labels': post.get('labels', []),
            'author': post.get('author', {}).get('displayName', '')
        }
        
        return json.dumps(post_data, indent=2)
    except HttpError as e:
        raise Exception(f"Blogger API error: {e.resp.status} - {e.error_details}")


@mcp.tool()
def blogger_get_post_labels(blogId: str, postId: str) -> str:
    """Get labels (tags) for a specific post
    
    Args:
        blogId: The ID of the blog
        postId: The ID of the post
    """
    if not blogger.service:
        blogger.init_service()
    
    try:
        post = blogger.service.posts().get(blogId=blogId, postId=postId, fields='labels').execute()
        labels = post.get('labels', [])
        
        return json.dumps(labels, indent=2)
    except HttpError as e:
        raise Exception(f"Blogger API error: {e.resp.status} - {e.error_details}")


@mcp.tool()
def blogger_create_post(
    blogId: str,
    title: str,
    content: str,
    labels: list[str] = [],
    isDraft: bool = True
) -> str:
    """Create a new blog post or draft
    
    Args:
        blogId: The ID of the blog
        title: Post title
        content: Post content (HTML supported)
        labels: Tags/labels for the post (empty list if none)
        isDraft: Whether to create as draft (default: true)
    """
    if not blogger.service:
        blogger.init_service()
    
    try:
        post_body = {
            'title': title,
            'content': content
        }
        
        if labels:
            post_body['labels'] = labels
        
        if isDraft:
            result = blogger.service.posts().insert(blogId=blogId, body=post_body, isDraft=True).execute()
        else:
            result = blogger.service.posts().insert(blogId=blogId, body=post_body).execute()
        
        response = {
            'id': result['id'],
            'title': result['title'],
            'url': result['url'],
            'status': result.get('status', ''),
            'published': result.get('published', ''),
            'message': 'Post created successfully'
        }
        
        return json.dumps(response, indent=2)
    except HttpError as e:
        raise Exception(f"Blogger API error: {e.resp.status} - {e.error_details}")


@mcp.tool()
def blogger_update_post(
    blogId: str,
    postId: str,
    title: str = "",
    content: str = "",
    labels: list[str] = [],
    publishAction: str = "none"
) -> str:
    """Update an existing post (title, content, labels, or publish status)
    
    Args:
        blogId: The ID of the blog
        postId: The ID of the post
        title: New post title (empty string = no change)
        content: New post content HTML (empty string = no change)
        labels: New tags/labels (empty list = no change)
        publishAction: "publish" to publish, "draft" to revert, "none" for no change
    """
    if not blogger.service:
        blogger.init_service()
    
    try:
        # Get current post
        post = blogger.service.posts().get(blogId=blogId, postId=postId).execute()
        
        # Update fields only if provided
        if title:
            post['title'] = title
        if content:
            post['content'] = content
        if labels:
            post['labels'] = labels
        
        # Handle publish action
        if publishAction == "publish":
            result = blogger.service.posts().publish(blogId=blogId, postId=postId).execute()
        elif publishAction == "draft":
            result = blogger.service.posts().revert(blogId=blogId, postId=postId).execute()
        else:
            result = blogger.service.posts().update(blogId=blogId, postId=postId, body=post).execute()
        
        response = {
            'id': result['id'],
            'title': result['title'],
            'url': result['url'],
            'status': result.get('status', ''),
            'updated': result.get('updated', ''),
            'message': 'Post updated successfully'
        }
        
        return json.dumps(response, indent=2)
    except HttpError as e:
        raise Exception(f"Blogger API error: {e.resp.status} - {e.error_details}")


@mcp.tool()
def blogger_update_post_labels(blogId: str, postId: str, labels: list[str]) -> str:
    """Update labels (tags) for a specific post
    
    Args:
        blogId: The ID of the blog
        postId: The ID of the post
        labels: New array of labels to set
    """
    if not blogger.service:
        blogger.init_service()
    
    try:
        # Get current post
        post = blogger.service.posts().get(blogId=blogId, postId=postId).execute()
        post['labels'] = labels
        
        # Update the post
        result = blogger.service.posts().update(blogId=blogId, postId=postId, body=post).execute()
        
        response = {
            'id': result['id'],
            'labels': result.get('labels', []),
            'message': 'Labels updated successfully'
        }
        
        return json.dumps(response, indent=2)
    except HttpError as e:
        raise Exception(f"Blogger API error: {e.resp.status} - {e.error_details}")


@mcp.tool()
def blogger_delete_post(blogId: str, postId: str) -> str:
    """Permanently delete a blog post
    
    Args:
        blogId: The ID of the blog
        postId: The ID of the post to delete
    """
    if not blogger.service:
        blogger.init_service()
    
    try:
        blogger.service.posts().delete(blogId=blogId, postId=postId).execute()
        
        return json.dumps({
            'message': f'Post {postId} deleted successfully',
            'blogId': blogId,
            'postId': postId
        }, indent=2)
    except HttpError as e:
        raise Exception(f"Blogger API error: {e.resp.status} - {e.error_details}")


@mcp.tool()
def blogger_upload_image() -> str:
    """Get instructions for uploading and embedding images in blog posts"""
    instructions = """
## Image Upload Instructions for Blogger

Blogger doesn't support direct image uploads via API. Use one of these methods:

### Method 1: Google Photos (Recommended)
1. Upload image to Google Photos
2. Right-click the image and select "Copy image address"
3. Use the URL in your HTML: `<img src="copied-url" alt="description">`

### Method 2: Google Drive
1. Upload image to Google Drive
2. Right-click → Get link → Anyone with the link can view
3. Extract the file ID from the URL
4. Use: `<img src="https://drive.google.com/uc?id=FILE_ID" alt="description">`

### Method 3: External Image Host
1. Upload to imgur.com, imgbb.com, or similar
2. Get the direct image URL
3. Embed in your post HTML

### HTML Example:
```html
<p>Here's an image:</p>
<img src="https://your-image-url.com/image.jpg" alt="Description" width="600">
```
"""
    return instructions


if __name__ == "__main__":
    logger.info(f"Starting Blogger MCP Server on port {PORT}")
    logger.info(f"Endpoint: http://0.0.0.0:{PORT}/mcp")
    
    # Run with streamable HTTP transport
    mcp.run(transport="streamable-http")
