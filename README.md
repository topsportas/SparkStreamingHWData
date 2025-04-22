# SparkSQL [Databricks]

## Prerequisites

Before proceeding, ensure you have the following tools and accounts set up:

- **AWS CLI** – Used to interact with AWS services and manage resources.
- **Terraform** – An Infrastructure as Code (IaC) tool for provisioning AWS resources.
- **Databricks Account** – You must have a Databricks account registered and configured. If you don't have an account, please create one here: https://login.databricks.com.
- **EPAM VPN Connection** – **Enable the EPAM VPN connection** to access internal services.

📌 **Important Guidelines**

Please carefully follow the instructions below to avoid errors:

- Any placeholder in the format `<PLACEHOLDER>` must be replaced with the appropriate value as described in the steps.
- Follow the steps in order to ensure proper setup.
- Pay attention to **bolded notes**, warnings, and important highlights throughout the guide.
- **Clean Up AWS Resources Before Proceeding:** If you are using a limited AWS account, ensure you clean up resources from previous deployments to avoid issues with quotas or limits.

---

## 1. Prepare Your Databricks Account

1. **Create a Databricks Service Account:**

   - Log in to your Databricks account.
   - Navigate to **Access Control** → **Service Accounts**.
   - Create a **Service Account**:
     - Give it a descriptive name (e.g., `databricks-service-account`).
     - Note down the **Service Account ID** and **Service Account Secret** – you'll need these later.
     - Ensure permissions are granted for programmatic access.

2. **Switch Subscription Plan to Enterprise:**
   - Go to your Databricks account settings.
   - Navigate to **Billing Plans**.
   - Select and subscribe to the **Enterprise plan**.

---

## 2. Authenticate with AWS

To interact with AWS services from the command line, you need to configure the AWS Command Line Interface (CLI) with your credentials. Follow these steps:

### Step 1: Get Your AWS Access Keys

You’ll need your AWS credentials (Access Key ID and Secret Access Key) to configure the AWS CLI:

1. Log in to the AWS Management Console: [AWS Management Console](https://aws.amazon.com/console/).
2. Navigate to **IAM (Identity & Access Management)** → **Users**.
3. Select your AWS user and go to the **Security Credentials** tab.
4. Under the **Access keys** section, click **Create access key**.
5. Note down the **Access Key ID** and **Secret Access Key** (you will need them in the next step). **Keep these keys secure, as they provide programmatic access to your AWS account.**

### Step 2: Configure the AWS CLI

Run the `aws configure` command in your terminal or command prompt to enter your credentials:

```bash
aws configure
```
You will be prompted to enter the following information:

1. **AWS Access Key ID:**
   Enter the Access Key ID you retrieved earlier.

2. **AWS Secret Access Key:**
   Enter the Secret Access Key you retrieved earlier.

3. **Default Region Name:**
   Enter the AWS region you want to use (e.g., `us-east-1`, `us-west-2`, etc.). This is the region where your resources are located.

4. **Default Output Format:**
   Enter `json` (default and widely used), `table`, or `text`. If you are unsure, use `json`.

Here’s an example session:

```bash
$ aws configure
AWS Access Key ID [None]: AKIAEXAMPLEACCESSKEY
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: us-east-1
Default output format [None]: json
```

---

## 3. Configure AWS SSM Parameters

AWS Systems Manager Parameter Store is used to securely store sensitive values. Follow these steps:

1. Open the AWS Management Console.
2. Navigate to **Systems Manager** → **Parameter Store**.

📌 **Important Guidelines for Parameter Naming**

<details>
  <summary>👇<strong> Before proceeding, carefully review the naming rules for SSM parameters:</strong> 👇 [⬇️⬇️⬇️ Expand for SSM Naming Rules ⬇️⬇️⬇️]</summary>

### 📝 **Naming Rules for AWS SSM Parameters**

- Allowed characters: Only **letters (A-Z, a-z)**, **numbers (0-9)**, hyphens `-`, and underscores `_`.
- Parameter names must be **unique** per account and region.
- Avoid long parameter names; aim for clear and descriptive names (e.g., `databricks_account_id` instead of `my_long_param_name_for_account`).

📖 **For complete naming rules, refer to the official documentation:**  
🔗 [AWS Systems Manager Naming Rules](https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-name-constraints.html)

</details>

3. Create the following parameters in **Parameter Store**:
   - `databricks_account_id`
   - `databricks_admin_sp_id`
   - `databricks_admin_sp_secret`

For each parameter:

- Set the value to the corresponding info from your Databricks account.
- Use **SecureString** as the type for sensitive values (e.g., `databricks_admin_sp_secret`).

---

## 3. Specify Your Username in `terraform.auto.tfvars`

Before deploying infrastructure, you need to specify your username in the `terraform.auto.tfvars` file located at the root of your project.

Open `terraform.auto.tfvars` and edit it:

Replace `<YOUR_USERNAME>` with your actual Databricks username. Your Databricks username is typically the email address you use to log in to the Databricks portal.

Also, ensure that the EPAM VPN connection is enabled before moving to the next steps.

## 4. Deploy Infrastructure in AWS

Terraform will provision the required resources in AWS for Databricks. Follow the steps below:

### **Steps to Deploy**

1. **Enable EPAM VPN Connection:**  
   Ensure that the **EPAM VPN connection is enabled** before proceeding to deploy infrastructure. This is required for accessing internal services.

2. **Initialize Terraform:**  
   To start the deployment using Terraform scripts, you need to navigate to the `terraform` folder.

```bash
cd terraform/
```

Run the following Terraform commands:

```bash
terraform init
```  

```bash
terraform plan -out terraform.plan
```  

```bash
terraform apply terraform.plan
```  

## 5. Launch Notebooks on Databricks Cluster

Follow the steps below to locate and access your AWS-associated Databricks workspace, create clusters, and run notebooks:

1. **Log in to the Databricks Account Console**
   - Navigate to the [Databricks Account Console](https://accounts.cloud.databricks.com/).
   - Log in using your credentials.

2. **Locate Your Workspace**
   - Once logged in, you’ll see a list of all associated workspaces.
   - Look for the workspace that matches your **AWS deployment**. Terraform often names the workspace following a pattern:
     - **`<ENV>-<LOCATION>-<random_suffix>`** (e.g., `dev-us-east-1-abc123`).

3. **Verify the Workspace Region**
   - After you open your workspace, confirm it matches the AWS region (e.g., `us-east-1`) where your infrastructure was deployed.
   - You can find the region by navigating to **Admin Console** → **Deployment Settings** in the Databricks UI.

4. **Access the Workspace**
   - Open the workspace using the URL retrieved the Account Console.
   - Log in using your Databricks credentials.

5. **Start Using Databricks**
    Once inside the Databricks UI, you can create clusters, notebooks, and start working with your data.

    - Open compute tab.
    - Press `Create compute` button.
    - Setting up the cluster settings: choose `Personale Compute`, in `Databricks Runtime Version` use basic preset (not ML). Recommended runtime version - 15.4. Then press the button `Create compute` (it will take some time 8-10 min).
    - Create notebooks, write code and launch them on created Databricks cluster

---

## 6. Destroy Infrastructure (Required Step)

After completing all steps, **destroy the infrastructure** to clean up all deployed resources.

⚠️ **Warning:** This action is **irreversible**. Running the command below will **delete all infrastructure components** created in previous steps.

To remove all deployed resources, run:

```bash
terraform destroy
```
