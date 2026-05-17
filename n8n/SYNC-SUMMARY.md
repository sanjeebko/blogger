# n8n Workflows Sync Summary

**Date**: January 26, 2026  
**Source**: n8n server at https://n8n.saasa.co.uk  
**Total Workflows Pulled**: 7 workflows

## Workflows Imported

### 1. **blog-generator.json** ✅

- **ID**: RPl6kytrnqkl7wlM
- **Status**: Active (main blog generation workflow)
- **Purpose**: AI-powered blog topic generation using Google Gemini + MCP Blogger tools
- **Key Features**:
  - Lists existing blog posts to avoid duplicates
  - Generates 2 new trending programming topics
  - Creates draft posts via MCP server at 192.168.1.60/mcp
  - Includes memory for context retention
- **Nodes**: 8 nodes (Manual Trigger, Gemini AI, MCP Client, AI Agent, Memory, JSON Parser, HTTP Create Post, Completion)

### 2. **blogger-mcp-create-if-missing.json** ⚠️

- **ID**: nBRYddJcbWqn4fEb
- **Status**: Archived
- **Purpose**: Conditional post creation (checks if title exists before creating)
- **Key Features**:
  - MCP session management
  - Lists posts and checks for duplicates
  - Only creates post if title doesn't exist
  - Uses raw HTTP requests to MCP server
- **Nodes**: 7 nodes (Manual Trigger, MCP Init, Set Session, List Posts, Check Exists, If Missing, Create Post)
- **Note**: Uses /mcp-n8n endpoint with session management

### 3. **generate-health-blogger.json** 📝

- **ID**: 1tRCiKxByMc6UWN1
- **Status**: Inactive
- **Purpose**: Health & fitness blog topic generator triggered by webhook
- **Key Features**:
  - Webhook trigger for external calls
  - Gemini generates 2 trending health topics
  - Calls another workflow (BlogGenerator) to process
- **Nodes**: 5 nodes (Webhook, Gemini Model, Code Parser, Split Out, Execute Workflow)
- **Webhook ID**: a7679299-4880-4784-9ec0-6095a6149521

### 4. **load-word-to-mongodb-dev.json** 🗄️

- **ID**: jjS7IZwixgPCi9st
- **Status**: Inactive (development workflow)
- **Purpose**: Dictionary word processing from SQL to MongoDB
- **Key Features**:
  - Scheduled trigger (every 2 minutes)
  - Queries SQL Server for unprocessed words
  - AI determines best word meaning using Ollama (mistral:latest)
  - Inserts processed words into MongoDB
  - Updates SQL processed flag
- **Nodes**: 9 nodes (Schedule, SQL Query, Convert File, Ollama Model, AI Agent, Memory, SQL Update, Code Parser, MongoDB Insert)
- **Note**: Not blogger-related, appears to be separate dictionary project

### 5. **select-data-from-sql.json** (saved as separate file below)

- **ID**: Kl2zZEpIma34Yq9p
- **Status**: Inactive
- **Purpose**: Batch word processor (calls MongoDbIngest for groups of words)
- **Key Features**:
  - Scheduled trigger
  - Groups words by distinct values
  - Calls MongoDbIngest workflow for each group
- **Nodes**: 4 nodes (Schedule, SQL Query, Group Code, Execute MongoDbIngest)

### 6. **mongodb-ingest.json** (saved as separate file below)

- **ID**: B2lPTK0CdEidRo0a
- **Status**: Inactive
- **Purpose**: Called by SelectDataFromSQL to process word groups
- **Key Features**:
  - Triggered by another workflow
  - Uses Ollama AI for word meaning extraction
  - Structured output parser for JSON format
  - Dual write (MongoDB + SQL update)
- **Nodes**: 9 nodes (Workflow Trigger, Ollama Models, AI Agent, Memory, SQL Update, Code Parser, MongoDB Insert, Structured Parser)

### 7. **gmail-labeller.json** (saved as separate file below)

- **ID**: zoruZE3tRDAVIUZH
- **Status**: Inactive
- **Purpose**: Automatic Gmail email labeling using AI classification
- **Key Features**:
  - Gmail trigger for unread emails
  - AI text classifier (Ollama deepseek-r1:1.5b)
  - 11 categories (Promotions, Social, Newsletters, Personal, Sales, Recruitments, OTP, Solicitors, Receipts, Misc, School)
  - Auto marks as read and removes from inbox
- **Nodes**: 18 nodes (Gmail Trigger, Text Classifier, Ollama Model, 11 Label Nodes, Merge, Mark Read, Remove Label)
- **Note**: Personal email automation, not blogger-related

## Blogger-Related Workflows

Primary workflows for the Blogger project:

1. ✅ **blog-generator.json** - Main blog generation with AI
2. ⚠️ **blogger-mcp-create-if-missing.json** - Conditional post creation
3. 📝 **generate-health-blogger.json** - Health blog topic generator

## Non-Blogger Workflows

These workflows are unrelated to the Blogger project but were imported for completeness: 4. 🗄️ **load-word-to-mongodb-dev.json** - Dictionary processing 5. 🗄️ **select-data-from-sql.json** - SQL word grouping 6. 🗄️ **mongodb-ingest.json** - MongoDB ingestion workflow 7. 📧 **gmail-labeller.json** - Personal email automation

## Next Steps

1. **Create metadata YAML files** for each workflow
2. **Review and update** MCP endpoint URLs if needed
3. **Test import** of workflows back to n8n server
4. **Document** workflow dependencies
5. **Archive** non-blogger workflows to separate folder

## MCP Server Endpoints Used

- **Production**: `http://192.168.1.60/mcp` (used by blog-generator)
- **Production with session**: `http://192.168.1.60/mcp-n8n` (used by blogger-mcp-create-if-missing)
- **Note**: Ensure MCP server is accessible from n8n server

## Credentials Referenced

The following credentials are referenced but NOT stored in workflow files (good practice):

- **Google Gemini API**: ID `12DKPRNOFpK0yTyy`
- **Microsoft SQL**: ID `kLWBEttuiVOg5QUX`
- **Ollama API**: ID `zyl6PeV6maQJ0cH2`
- **MongoDB**: ID `7DL5DScLmggl3F1x`
- **Gmail OAuth2**: ID `mhzukC7BbBy3Zy2F`

These must be configured in your n8n instance before workflows can run.

---

_Auto-generated by n8n workflow sync on 2026-01-26_
