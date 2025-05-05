# Intune App Sync

Automated solution to sync app install status from Intune-managed devices to Azure AD using PowerShell, Proactive Remediation, and Microsoft Graph API.

---

## 📌 Project Overview

This project enables organizations to dynamically track application installations (e.g., Zoom, Chrome) on Intune-managed devices and reflect that status in Azure AD using custom schema extensions. This allows for dynamic group membership, compliance reporting, and targeted deployments.

---

## ✨ Features

- Detect app installations using PowerShell
- Store app status in the Windows Registry
- Sync registry values to Azure AD via Graph API
- Use Azure AD dynamic groups based on app presence

---

## 🧱 Architecture

1. **Device Script**: Checks for app install and writes to registry
2. **Azure Automation Runbook**: Reads registry remotely and updates Azure AD
3. **Azure AD Schema Extension**: Stores custom device attributes
4. **Dynamic Groups**: Use extension attributes for targeting

---

## 🔧 Prerequisites

- Azure AD Premium P1 or P2
- Microsoft Intune
- Azure Automation Account
- App Registration with Graph API permissions
- Devices enrolled in Intune

---

## 🚀 Setup Instructions

### 1. App Registration in Azure AD

- Register a new app in Azure AD
- Add API permissions:
  - `Directory.ReadWrite.All`
  - `Device.Read.All`
  - `User.Read.All`
- Grant admin consent
- Create a client secret and note:
  - Tenant ID
  - Client ID
  - Client Secret

### 2. Create Schema Extension

Use Graph Explorer or Postman:

```http
POST https://graph.microsoft.com/v1.0/schemaExtensions
Content-Type: application/json

{
  "id": "com_company_appstatus",
  "description": "Custom extension for app install status",
  "targetTypes": ["Device"],
  "properties": [
    {
      "name": "zoomInstalled",
      "type": "String"
    }
  ]
}
