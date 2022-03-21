##
##  Lambda  releases provided by Terraform and Github Action
##

# Purpose:  The POC consist to provide new releases of a lambda function when someone does a push to lambda-prod branch

# Solution Diagram


<p align="center">
  <img src="./aws/lambda-tf-githubaction/img/githubaction-workflow.png" alt="WorkFlow Github" width="738">
</p>

# List of tecnologies used in this POC
* AWS lambda function
* AWS API Gateway
* Terraform
* Github Action



| Tecnologies              | Purpose           |
| ------------------------ |:-----------------:|
| AWS lambda function      | It store a simple function in **nodejs** to display a hello world              |
| AWS API Gateway          | acts as  bridge between our AWS service and external apps                  |
| Terraform                | Has the steps required to provision an **AWS** infrastructure         |
| Github Action            | It makes easy to automate our workflow, when someone does a push           |
| Script Bash              | Github action is going to provide an container on Ubuntu on each execution <br> We are going to leverage the  terminal console to execute aws commands |


The POC has 2 folders
infra : it has the followings files
 * `api-gateway.tf`  terraform manifest regarding api-gateway, You can see all resources that we are using to this POC
 * `iam.tf`  terraform manifest regarding iam resources with lambda function
 * `lambda.tf`  terraform manifest with all resources required to create a lambda function
 * `main.tf`  terraform manifest to declare the version that is going to use with aws provider
 * `output.tf`  


 lambda: the folder stores the code of nodejs app and the zip file to upload in aws lambda

 publish.sh : bash script that is going to be called from github action


 # --------------  LESSONS LEARNED  ---------

 `GITHUB ACTIONS`
* SHARE VARIABLES
   You can pass a value from a step in one job in a workflow to a step in another job in the same WORKFLOW
   BUT you should define the value as a job output

   Defining outputs
```MiniYAML
  retrieveIDs:
    runs-on: ubuntu-latest
    outputs:
      output1: ${{ steps.ID_STEP.outputs.OUTPUT_ID }}

```

  How to use them in other Jobs.

  *IMPORTANT
   You should define as prerequisite jobs in the job that want to access to output
   using the needs property

```MiniYAML

  addPermission:
    runs-on: ubuntu-latest
    needs: [retrieveIDs, createAlias]
    steps:
   - name: Add permission on Lambda function
      run: |
        ./aws/lambda-tf-githubaction/publish-by-jobs.sh prod addPermission ${{ needs.retrieveIDs.outputs.output1 }} ${{ needs.retrieveIDs.outputs.output2 }}

```

* HOW TO SHARE DATA BETWEEN JOBS
there are 2 ways to share data between jobs in Github Actions
1. Cache
2. Artifacts

I decided to use the second.
I will explain how to use it.

In the following snippet, We are uploading the path aws/lambda-tf-githubaction/
and all files on that one are going to upload as artifactor

```MiniYAML

    - name: Upload clone directory
      uses: actions/upload-artifact@v2
      with:
        name: repo
        path: aws/lambda-tf-githubaction/

```

Downloading the artifactor in other job

```MiniYAML
    - name: Download artifacts
      uses: actions/download-artifact@v2
      with:
        name: repo
        path: aws/lambda-tf-githubaction/

```

and that's all, the job is going to download it.