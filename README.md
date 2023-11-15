## <ins>Deployment 6: Retail Banking Flask Application Across Two Regions through a Jenkins Agent Infrastructure using Terraform</ins>
_________________________________________________
##### Danielle Davis
##### October 28, 2023
______________________________________
### <ins>PURPOSE:</ins>
________________________________________

&emsp;&emsp;&emsp;&emsp;	To provision my Jenkins infrastructure in my default VPC and utilize Terraform and Docker to automate the creation of my infrastructure needed to deploy my application through my containers managed through AWS ECS(Elastic container service). I utillized Terraform to construct my Jenkins infrasructure, with a main Jenkins server that manages 2 distributed and decentralized agent nodes on 2 separate servers with Terraform and Docker installed on each. These agent nodes allowed me to automate the creation of my application infrastructure listed within myintTerraform directory. Compared to previous deployments, using Docker allowed me to access my application through my load balancer on my container. Instead of having to manually install software and include the files that my application needed to work with Flask and Gunicorn, Docker created an image of my GitHub repo, my version control system. Providing Jenkins with my GitHub credentials, allows Jenkins to integrate with the latest version of my application code files to orchestrate my pipeline that tests, builds, and manages my application deployment on ECS. Meanwhile my ECS cluster, configured with services and tasks definitions, uses AWS Fargate to connect and manage all the components of my application infrastructure --my Jenkins infrastructure and my container housing my application's image-- to deploy my application.    

________________________________________
### <ins>ISSUES:</ins>
________________________________________
* Terraform: I had issues figuring out how to connect my Jenkins infrastructure to my default VPC. I realized I did not need to include resource blocks for a new subnet or security group because AWS creates a default subnet when my default VPC was created and I needed to use the specific security group that was already associated with my default VPC or Terraform won't recognize the new resources that it tries to create.

* Jenkins pipeline: My Jenkins pipeline wasn't failing because I did not include *sudo usermod -aG docker* in my docker installation script for my Docker agent server which add docker as a user instead of the root. After adding this, Jenkins was able to recognize my server. I also had to make sure that I put my AWS credentials into Jenkins properly with the ID and description matching how my variables were labeled in my [Jenkinsfile](Jenkinsfile).
________________________________________________________________________________

### <ins> **STEPS FOR WEB APPLICATION DEPLOYMENT** </ins>

_________________________________________________________________________________
### Step 1: Diagram the infrastructure for Web Application Deployment
_________________________________________________________________________________


![system_diagram](static/images/updated5.1systemd.jpg)


______________________________________________________________________________
### Step 2: Git commits & Repo Changes 
__________________________________________________________________________

* *git clone* - Used VS code editor to easly make changes to my remote repo on GitHub
*  *cd .git*, *nano config* - Added my GitHub URL in my .git config file to give VS code permission to push changes to my remote repo on GitHub after creating my terraform files and scripts for my infratucture.
*  *git branch* - to make changes in second branch to make changes before adding to the main branch
*  *git add .* - to update changes in each branches
*  *git commit -m "message"* - to finalize changes to repo with message description
*  *git push* - push changes back to remote GitHub repo  

_____________________________________________________________________________
### Step 3: Create Jenkins Infrastructure with Terraform:
__________________________________________________________________________
	
* Terraform is a great tool to automate the building of your application infrastructure instead of manually creating new instances with different installations separately. For this application, I wrote a terraform [Jenkins.tf](Jenkins.tf) file script in VS code with defined variables and values. This infrastructure included 3 servers -- one for the [Jenkins manager](jenkins-deadsnakes.sh) and the other two installed with [Terraform](terraform-java.sh) and [Docker](docker-deadsnakes.sh), provisioned to connect to my Jenkins agent nodes.
* My second set of terraform files was for my application infrastructure which included: 

With a public and private subnet each in 2 separate availability zones ensures that our application is available in case one AZ goes down in the [VPC](intTerraform/vpc.tf): 
**2 AZ's 
**2 Public Subnets
**2 Private Subnets
**1 Application Load Balancer (directs traffic to both containers)*
**1 Internet Gateway (necessary for ingress traffic to reach the application servers/containers on port 8000 located in the private subnet)*
**1 NAT Gateway (necessary for egreess traffic to go out and return responses to HTTP request that lies in the public subnet in order to connect to have a connection to the internet through the internet gateway)*
**2 Route Table (for each subnet)*
**2 Security Groups (with ports: 80 for the [ALB](intTerraform/ALB.tf) to listen through and direct traffic to port 8000 for Gunicorn production web server)*

[**main.tf**](intTerraform/main.tf) created the cluster environment that housed our 2 tasks/containers defined in our service resource block which is connected to our application load balancer listening on port 8 and directs traffic to port 8000. 

**Configure RDS Database**
____________________________________________________________________________
* Using the AWS RDS Database, allowed me to separate my data logical layer from my application servers that frees up space and reduces resource container for processing power (CPU, RAM, MEM). 
* This AWS managed service allowed me not to worry about the operation of the data layer and focus on the rest of the infrastructure.
* I used the username and password I made for additonal security on the database that is also in the prvate subnet which helps block users from accessing sensitive information, the endpoint for the container/application servers to locate the database system and return the information being requested, and the name of my databse in the databse files to connect my RDS Datbase to my application infrastructure:
  
**[load_data.py](load_data.py)**: loads the data being requested 

**[database.py](database.py)**: holds proprietary information that puts account holders at risk if anyone was able to access it. RDS Database and private subnet provide layers of security. 

**[app.py](app.py)**: utilizes Flask for generating the web page, uses SQLAlchemy to connect with SQLite database, and uses rest APIs to render necessary information for customers, accounts, transactions, etc. of a banking web application.
________________________________________________
### Step 6: Jenkins Staging Environment
__________________________________________________________

* Provided my AWS credentials to allow Jenkins to access my cluster environment on my AWS account and the Docker token to retrieve the image of my application in DockerHub to store Docker images.

* The [Dockerfile](Dockerfile) constructs the image of my application that can be easily reused for scalability because the server can easily replicate more containers for vertical scalability or on more servers for horizontal scalability and reduce the risk of configuration drift becasue the structure of the application and its dependencies can be accessed by: pulling from a python environment that runs the database files, installs the requirements file, and installs sqlite so the application can use the sqlite database along with gunicorn to access and start the application. Since Gunicorn is running as a background process, the agent servers have more capacity to handle multiple tasks at the same time.

* "Pipeline keep running plugin" is used to run the Jenkins build for as long as the applicaiton is up and running on the servers and "Docker Pipeline plugin" to configure my Jenkins pipeline to allow me to build my infrastructure straight into my containers in my ECS cluster. 

* Create Jenkins **Multibranch Pipeline** to build staging environment: Find instructions to access Jenkins in the web browser, create a multibranch pipeline, and create a token to link the GitHub repository with the application code to Jenkins.


<ins> **[Jenkinsfile](https://github.com/DANNYDEE93/Deployment-5.1/blob/main/Jenkinsfile):** </ins>

* Docker hub credentials and **Agent nodes**: The Jenkins manager server distributes the same information about the app infrastructure to each agent server installed with Terraform to allow me to use both in automating the creation of my infrastructure, including the creation of my ECS cluster environment and dependencies (tasks and services) that uses the image of my application from Docker Hub which is updated through my Jenkins pipeline whenever there are changes to my GitHub repo.

* The main Jenkins server delegates work to the agent nodes making it easier to scale my builds across multiple machines when necessary to handle resource contention and increase performance. Agent nodes also continuously run builds so if my main server goes down, the application can still initialize for deployment. Utilizing agent nodes is essentially installing a virtual machine on my EC2 virtual machine which increases allotted CPU, RAM, and MEM resources to increase the speed of my running processes.

<ins> **Docker Stages**: </ins> Automated the build of my containers from my Docker image, login into my DockerHub, and pushes the latest update to my image on DockerHub. 

<ins> **Terraform stages:** </ins> Automated the execution of my infrastructure through *Init, Plan, Apply*. 

*Terraform init: to initialize terraform and the backend configurations*
*Terraform validate: to validate that the terraform file is configured properly*
*Terraform plan: to show exactly what will be created when applied*
*Terraform apply: to execute infrastructure script*

____________________________________________________________________________
### Step 7: Gunicorn Production Environment on Web Application Server
__________________________________________________________________________

* Gunicorn, installed in our Jenkinsfile application code, acts as my application's production web server running on the exposed port of 8000 in my Dockerfile and in my security groups in my application infrastructure terraform files. The flask application, installed through the app.py and load_data.py scripts, uses Python with Gunicorn to create a framework or translation of the Python function calls into HTTP responses so that Gunicorn can access the endpoint which is encoded into my database files and connected to my RDS Database server.
  
___________________________________________

### <ins>CONCLUSION & OPTIMIZATION:</ins>
_____________________________________________

Jenkins was particularly important in the optimization and error handling of the deployment. The use of DockerHub and Terraform gives me a smoother workflow through my pipeline by continuously integrating updated Docker images of my app infrastructure, continuously developing and deploying my app through ECS, and Terraform allows me to automate the code to provision the resources necessary for the applicaiton. Utilizing the AWS RDS Database gives me a 2-tier architecture with three logical layers by separating the database layer on my RDS Database and my application layer on my containerized images accessed through ECS. 

* Increased security by housing my containers in my private subnet and RDS Database secures my infrastructure from unwanted access.
* Makes my infrastructure fault-tolerant by deploying my application in separate availability zones.
* Increased resiliency with lower risks of latency by provisioning 2 containers managed in ECS so in case one goes down, the traffic will run to the working one.
* Increased scalability through easily constructed and replicated Docker images, as well as, management under AWS Fargate, which is a serverless service that runs in the background and provides the necessary configurations for the operation AWS ECS.

<ins> **Ways to optimize and increase user availability of my deployment:** </ins>

<ins>Enhancing the automation of the AWS Cloud Infrastructure:</ins> 

 * Implementing Terraform modules(reusable infrastructure definitions to reduce error and increase efficiency). 

 * Including "aws_autoscaling_policy" resource within my saved infrastructure code in Terraform to scale up or down as needed (ex. when resources like CPU reach a certain utilization), detect unhealthy instances and replace them, and automate recovery by redeploying failed instances.

