# 🛡️ Automated DevSecOps Pipeline: Azure Infrastructure Guardrail

## 📖 Executive Summary

An automated CI/CD security guardrail built to enforce Policy-as-Code (PaC) for Azure cloud infrastructure. This pipeline uses **GitHub Actions** and **Checkov** to automatically scan Terraform configurations during pull requests. When configured as a required status check through GitHub branch protection, the pipeline blocks non-compliant Terraform from being merged into the `main` branch.

This project demonstrates the DevSecOps principle of **shifting security left** by identifying high-risk cloud misconfigurations at the code review stage instead of waiting for runtime alerts or manual security reviews.

## 🛠️ Technology Stack

* **Infrastructure as Code:** Terraform
* **Cloud Provider:** Microsoft Azure
* **Policy-as-Code / Static Analysis:** Checkov
* **CI/CD Automation:** GitHub Actions
* **Version Control:** Git & GitHub

## ⚙️ Pipeline Architecture & Workflow

1. **Trigger:** An engineer opens a pull request containing Terraform changes targeting the `main` branch.
2. **Runner Environment:** GitHub Actions provisions an ephemeral Ubuntu runner and configures a Python 3.11 environment.
3. **Static Analysis:** The workflow checks out the repository, installs Checkov with `pip`, and scans the Terraform configuration.
4. **Custom Policy Loading:** The pipeline explicitly loads organization-specific Checkov policies using the `--external-checks-dir` flag.
5. **Security Gate:** If Checkov identifies a built-in Azure policy violation or a custom organizational policy violation, the scan exits with a failing status and prevents the pull request from passing CI.

## 🚨 Proof of Concept: Detection & Remediation

To validate the guardrail, I tested both an intentionally insecure Terraform configuration and a remediated secure configuration.

## 1. Detection: Insecure Infrastructure

I validated an intentionally insecure Azure Storage Account Terraform configuration (`insecure/main.tf`) containing high-risk security misconfigurations, including allowing nested blob containers to be made public. This increases the risk of accidental public data exposure.

**Result:** The GitHub Actions pipeline identified the security policy violations and failed the workflow.

<img width="604" height="188" alt="Failed GitHub Actions required check for insecure Terraform configuration" src="https://github.com/user-attachments/assets/0ab03066-43bc-4ecb-80cb-19e6bd3a819f" />

<img width="1656" height="939" alt="Checkov findings showing Azure Storage Account security policy violations" src="https://github.com/user-attachments/assets/194822fe-9f63-4363-8cf2-f0a95ae7b1f3" />

## 2. Remediation: Secure Infrastructure

I validated a remediated Terraform configuration (`secure/main.tf`) with corrected Azure Storage Account controls, including enforced TLS 1.2, HTTPS-only traffic, and disabled nested public access.

**Result:** Checkov successfully validated the secure Terraform configuration, allowing the pipeline to pass.

<img width="1916" height="946" alt="Passing GitHub Actions workflow after Terraform security remediation" src="https://github.com/user-attachments/assets/f78adee3-9759-4de0-a8c3-718ca1056524" />

<img width="1678" height="914" alt="Checkov scan output showing successful validation of remediated Terraform configuration" src="https://github.com/user-attachments/assets/b674ce84-60c6-48d2-8646-10467e38c5a6" />

## 3. Baseline Tuning & Risk Acceptance

Enterprise security scanners can introduce noise when enforcing policies that are outside the current project scope. To make the pipeline more production-minded, I implemented two levels of tuning:

* **Global Baseline Tuning:** Updated the Checkov execution command with `--skip-check` to silence out-of-scope policies, such as queue logging and private endpoint requirements, until those controls are formally adopted.
* **Resource-Level Risk Acceptance:** Used Checkov inline suppressions, such as `#checkov:skip=CKV2_AZURE_1`, directly inside Terraform resource blocks to document accepted risks without failing the pipeline.

## Key Azure Policies Tested

* ❌ **CKV_AZURE_59:** Ensures Azure Storage Accounts disallow public access.
* ❌ **CKV_AZURE_44:** Ensures Azure Storage Accounts use TLS 1.2 or newer.
* ⚠️ **CKV2_AZURE_1:** Ensures storage for critical data is encrypted with Customer Managed Keys. This was handled through documented inline suppression for the demo scenario.
* ❌ **CKV_CUSTOM_1:** Custom policy ensuring Azure Storage Accounts do not allow public nested items.

## 💼 Business Impact

* **Automated Security Guardrails:** Enforces tested Terraform security controls during pull requests, flagging non-compliant infrastructure before merge.
* **Reduced Manual Review Burden:** Provides developers with actionable Checkov findings directly inside the CI/CD workflow.
* **Policy-as-Code Enforcement:** Extends built-in Azure security checks with custom organizational guardrails.
* **Auditability:** Documents remediation evidence, baseline tuning decisions, and accepted-risk suppressions for security review.
* **Shift-Left Cloud Security:** Moves Azure misconfiguration detection earlier in the development lifecycle, reducing the likelihood of insecure infrastructure reaching production.
