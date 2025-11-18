# Blogger Workspace

A comprehensive collection of blog articles on technology and health topics, along with n8n workflow automation templates.

## ?? Project Structure

```
blogger/
??? blogs/                      # Blog articles organized by category
?   ??? index.html             # Main blog index page
?   ??? computer/              # Technology & programming articles
?   ?   ??? 1/ - C# 14 Feature Guide
?   ?   ??? 2/ - .NET 9 Feature Guide
?   ?   ??? 3/ - Diagnosing .NET Container Crashes in Kubernetes
?   ?   ??? 4/ - What is Hardware?
?   ?   ??? 5/ - What is Software?
?   ?   ??? 6/ - What is an Operating System?
?   ?   ??? 7/ - What is a CPU?
?   ?   ??? 8/ - What is RAM?
?   ?   ??? 9/ - What is the Internet?
?   ??? health/                # Health & wellness articles
?       ??? 10/ - Weight Loss & Diet Plans
?       ??? 11/ - Exercise Routines & Workouts
?       ??? 12/ - Healthy Eating & Nutrition
?       ??? 13/ - Mental Health & Stress Reduction
?       ??? 14/ - Sleep Improvement
?       ??? 15/ - Understanding Health Symptoms & Conditions
?       ??? 16/ - Supplements & Vitamins
?       ??? 17/ - Body Pain Management
?       ??? 18/ - Heart Health
?       ??? 19/ - Hydration Essentials
?       ??? 20/ - Intermittent Fasting Guide
?
??? n8n-workflows/             # Workflow automation templates
    ??? workflows/             # n8n workflow JSON definitions
    ??? metadata/              # Workflow metadata in YAML
    ??? scripts/               # Import/export scripts
    ??? .github/workflows/     # CI/CD automation

```

## ?? Blog Collection

### ?? Computer & Technology (9 Articles)
Comprehensive guides on programming languages, system architecture, and technical concepts:
- **C# 14** - Latest features and improvements
- **.NET 9** - Cloud-native excellence
- **Kubernetes** - Container debugging and diagnostics
- **Computer Fundamentals** - Hardware, Software, OS, CPU, RAM, Internet

### ?? Health & Wellness (11 Articles)
Evidence-based health guides covering:
- Weight loss and diet plans (Keto, Intermittent Fasting, Mediterranean)
- Exercise routines and workout plans
- Nutrition and healthy eating
- Mental health and stress management
- Sleep optimization
- Supplements and vitamins
- Pain management
- Heart health
- Hydration
- And more...

## ?? n8n Workflows

Version-controlled n8n workflow templates with automated deployment via GitHub Actions.

### Sample Workflows:
1. **CRM to Sheets Sync** - Automated data synchronization
2. **Daily Report Dispatch** - Scheduled email reports
3. **Backup Automation** - Automated backup to AWS S3

### Features:
- ? Export/Import scripts using n8n REST API
- ? YAML metadata for each workflow
- ? CI/CD deployment via GitHub Actions
- ? Comprehensive documentation

See [n8n-workflows/README.md](n8n-workflows/README.md) for detailed workflow documentation.

## ?? Quick Start

### Viewing Blogs
1. Open `blogs/index.html` in your browser
2. Browse articles by category
3. Click on any article to read

### Using n8n Workflows
1. Set up n8n server
2. Configure environment variables:
   ```bash
   export N8N_HOST="http://localhost:5678"
   export N8N_API_KEY="your-api-key"
   ```
3. Import workflows:
   ```bash
   cd n8n-workflows
   chmod +x scripts/*.sh
   ./scripts/import-workflow.sh workflows/backup-automation.json
   ```

## ?? Features

### Blog Index
- ? Responsive design
- ? Category organization
- ? Beautiful gradient themes
- ? Mobile-friendly
- ? Hover effects and animations
- ? Emoji icons for visual appeal

### Individual Blog Posts
- ? Comprehensive content with examples
- ? Styled code blocks
- ? Information boxes (tips, warnings, highlights)
- ? Tables and visual guides
- ? Professional typography
- ? Print-friendly layouts

## ?? License

This project is open source and available for educational purposes.

## ?? Contributing

Feel free to:
- Report issues
- Suggest new blog topics
- Submit workflow templates
- Improve documentation

## ?? Contact

For questions or suggestions, please open an issue on GitHub.

---

**Last Updated:** January 2024  
**Total Articles:** 20  
**Categories:** Technology (9), Health (11)
