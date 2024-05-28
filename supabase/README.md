# README

## Overview

This folder contains the necessary files for deploying the ActualIA site using Cloudflare Pages. The deployment process is done manually, and this document explains the steps involved and the purpose of the included HTML file.

## Contents

- `index.html`: The HTML file for the ActualIA site.

## Deployment Instructions

To deploy the site using Cloudflare Pages manually, follow these steps:

1. **Log in to Cloudflare**:
   - Go to the Cloudflare website and log in to your account.

2. **Create a new Cloudflare Pages project**:
   - Navigate to the Cloudflare Pages dashboard.
   - Click on "Create a project".
   - Select the repository containing this folder (if not already connected, connect your GitHub repository).

3. **Configure the project**:
   - In the project settings, set the following:
     - **Build command**: (Leave it empty, as we are deploying a static file).
     - **Build output directory**: Enter the path to the `supabase` folder (e.g., `supabase`).

4. **Deploy the site**:
   - Click on "Save and Deploy".
   - Wait for the deployment to complete. Once deployed, you will have a URL where your site is accessible.

## HTML File Explanation

The included `index.html` file contains a script that performs URL parameter extraction and redirection based on the `transcriptId` parameter. Here's a breakdown of its functionality:

### Script Explanation

- **Function `getParameterByName`**:
  - This function extracts a specified parameter (`name`) from the URL.
  - It uses a regular expression to locate the parameter and returns its value.

- **Parameter Retrieval**:
  - The script retrieves the `transcriptId` parameter from the URL.

- **Conditional Redirection**:
  - If the `transcriptId` parameter is present, the script constructs a redirect URL using this parameter and redirects the browser to this URL.
  - If the `transcriptId` parameter is missing, it displays a message ('ActualIA') on the webpage.

This setup allows the site to dynamically redirect users based on URL parameters, enhancing user experience by providing specific content based on the provided `transcriptId`.
