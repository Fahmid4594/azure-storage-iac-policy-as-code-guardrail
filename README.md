# 🛡️ Automated DevSecOps Pipeline: Azure Infrastructure Guardrail

## 📖 Executive Summary
An automated CI/CD security guardrail built to enforce Policy-as-Code (PaC) for Azure cloud infrastructure. This pipeline utilizes **GitHub Actions** and **Checkov** to automatically scan Terraform configurations on every Pull Request. When configured as a required status check in GitHub branch protection, this pipeline successfully blocks insecure Terraform from being merged into the `main` branch.

This project demonstrates the core DevSecOps principle of "Shifting Left"—identifying and remediating critical misconfigurations at the code commit stage rather than waiting for cloud runtime alerts.

## 🛠️ Technology Stack
* **Infrastructure as Code (IaC):** Terraform
* **Cloud Provider:** Microsoft Azure
* **Policy-as-Code / Static Analysis:** Checkov (Prisma Cloud)
* **CI/CD Automation:** GitHub Actions
* **Version Control:** Git & GitHub

## ⚙️ Pipeline Architecture & Workflow
1. **The Trigger:** An engineer opens a Pull Request to merge new Terraform code into the `main` branch.
2. **The Environment:** GitHub Actions provisions an ephemeral Ubuntu Linux runner and configures a Python 3.11 environment.
3. **The Execution:** The runner checks out the repository, installs the Checkov engine via `pip`, and executes a static analysis scan against the Terraform directory, explicitly loading custom organizational policies via the `--external-checks-dir` flag.
4. **The Gate:** If Checkov detects a violation of Azure security benchmarks (CIS/NIST) or custom organizational policies, it throws an `exit code 1`, failing the CI check.

## 🚨 Proof of Concept: Detection & Remediation
To validate the guardrail, I tested both an insecure configuration (to trigger the block) and a secure configuration (to validate the remediation).

### 1. Detection: The Insecure Infrastructure
I deliberately attempted to deploy an Azure Storage Account (`insecure/main.tf`) configured with critical vulnerabilities, notably configuring it to allow nested blob containers to be made public, thereby increasing the risk of accidental public data exposure.
* **Result:** The GitHub Actions pipeline intercepted the PR, identified security policy violations, and failed the workflow.
![Pipeline Failure](./images/pipeline-failure.png)

### 2. Remediation: The Secure Infrastructure
I deployed a secondary Terraform file (`secure/main.tf`) with corrected configurations, including enforced TLS 1.2, forced HTTPS traffic, and disabled nested public items. 
* **Result:** Checkov successfully validated the secure infrastructure, allowing the pipeline to pass.
![Checkov Logs](./images/checkov-logs.png)

### 3. Advanced Configuration: Baseline Tuning & Risk Acceptance
Enterprise scanners often introduce pipeline noise by enforcing rules outside the current organizational scope. To make this pipeline production-ready, I implemented two levels of tuning:
* **Global Baseline Tuning:** Modified the Checkov execution command with `--skip-check` to globally silence specific noise (e.g., Queue Logging, Private Endpoints) until the engineering team is ready to adopt those standards.
* **Inline Suppressions:** Utilized Checkov's regex-based inline comments (`#checkov:skip=CKV2_AZURE_1`) directly within the Terraform resource blocks to document explicitly accepted risks (e.g., opting out of Customer Managed Keys for non-critical storage) without failing the pipeline. 

### Key Azure Policies Enforced During This Run:
* ❌ **CKV_AZURE_59:** Ensure that Storage accounts disallow public access
* ❌ **CKV_AZURE_44:** Ensure Storage Account is using the latest version of TLS encryption (TLS 1.2+)
* ⚠️ **CKV2_AZURE_1:** Ensure storage for critical data are encrypted with Customer Managed Key *(Handled via documented inline suppression)*
* ❌ **CKV_CUSTOM_1:** Custom policy ensuring Azure Storage Accounts do not allow public nested items

## 💼 Business Impact
* **Automated Guardrails:** Provides automated enforcement for tested Terraform guardrails, ensuring non-compliant infrastructure is flagged before deployment.
* **Accelerated Developer Velocity:** Reduces the security review bottleneck by providing engineers with actionable remediation feedback inside their terminal.
* **Enterprise-Grade Compliance:** Evaluates infrastructure against multiple built-in Azure security policies, with support for CIS/NIST-aligned checks and custom organizational logic.
