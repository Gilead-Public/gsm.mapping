# Requesting New Domains or Variables

## Step-by-Step Instructions for Submitting a Request

This guide provides detailed instructions for users on how to submit
requests for adding new domains or variables to `gsm.mapping`.

------------------------------------------------------------------------

### 1. **Navigate to the GitHub Issues Page**

1.  Visit the repository’s GitHub
    [page](https://github.com/Gilead-Public/gsm.mapping).
2.  Click on the **Issues** tab located at the top of the repository
    page and click the green **New Issue** button.
3.  Or click
    [here](https://github.com/Gilead-Public/gsm.mapping/issues/new/choose)

### 2. **Open a New Issue**

1.  Select the template labeled **“Request New Domain or Variable”**.

### 3. **Complete the Request Template**

Provide detailed and clear information to ensure the request can be
addressed efficiently. Use the following structure:

#### A. **Request Title**

- Use the format:
  `Request for New Domain/Variable: [Domain Name or Variable Name]`

#### B. **Details Section**

Complete the following fields:

1.  **Domain Name** (if applicable):
    - Provide the name of the domain (e.g., `AE` for Adverse Events,
      `LB` for Laboratory Tests).
    - If this domain has dependencies on other domains, please specify
      them. (e.g. the `COUNTRY` domain depends on `SUBJ` domain.) This
      will help aid the priority/order in which the workflow is run.
2.  **Variable Name(s):**
    - List the variable(s) you need added (e.g., `AESEV` for Adverse
      Event Severity).
    - If this variable has an original source, provide the name of the
      source column.
3.  **Variable Metadata:**
    - Provide detailed metadata for each variable, including:
      - Expected Data Type (e.g., character, numeric, Date, timestamp,
        logical)
4.  **Rationale for Addition:**
    - Explain why this domain or variable is important for your
      monitoring needs. Include specific use cases if possible.
5.  **Example Data:**
    - Provide example data or mock-up rows illustrating how the domain
      or variable should look in the pseudo-SDTM format.
6.  **References (if any):**
    - Include any references to regulatory guidance, protocol
      requirements, or study documentation supporting this request.

#### C. **Additional Context (Optional)**

- Add any additional context, such as:
  - Link to related issues or discussions.
  - Challenges you are facing without this domain or variable.

### 4. **Submit the Issue**

1.  Review your request for completeness and accuracy.
2.  Click the **Submit new issue** button.

### 5. **Follow Up on the Request**

- Monitor your issue for updates or comments from the maintainers.
- Respond promptly to any questions or requests for clarification.
- Collaborate with the team as needed to finalize the implementation.
