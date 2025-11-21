
Java JDK 11+ installed and JAVA_HOME set.

Maven installed (or Jenkins configured with Maven tool).

Jenkins installed and admin access. Jenkins host is same machine as Tomcat (this guide assumes that; if remote, see notes below).

Tomcat 9 installed and running locally (you indicated Tomcat 9 works; confirm port).

Git installed and accessible from Jenkins and from the server machine.

Your repository is public (no auth); if private, add credentials to Jenkins.

A. Confirm environment & basic checks

Open a terminal (Windows PowerShell or CMD) on the Jenkins host and run:

java -version
mvn -version
git --version


Screenshot the output.

Check Tomcat 9 is reachable in a browser:

http://localhost:<tomcat-port>/


Example: http://localhost:8082/ (your working port). Screenshot Tomcat home with version visible.

Make sure Jenkins is reachable:

http://localhost:8080/    (or your Jenkins port)


Login as admin. Screenshot Jenkins home.

B. Build job (verify Jenkins produces the WAR)

We already did this once, but reproduce as a solid step so pipeline will use it.

1. Create Freestyle Job SE-Build

Jenkins → New Item → SE-Build → Freestyle project → OK.

Source Code Management → Git → Repository:
https://github.com/rayyanahmed26042005/SE.git
Branch: */main (or master if your repo uses master).

Build Environment: leave default.

Build → Add build step → “Invoke top-level Maven targets”:

Maven version: select installed Maven (e.g. Maven-3.9)

Goals: clean package

Post-build Actions: optional: Archive the artifacts **/target/*.war (helpful).

Save → Build Now → Click build number → Console Output → wait for success.

Verify event-app.war exists: Jenkins job workspace → target/event-app.war. Screenshot workspace listing showing the WAR.

C. Configure Tomcat for automatic deployment (prepare Tomcat)

We will use Tomcat Manager / manager-script and Jenkins “Deploy to container” plugin. Alternatively, you can copy/paste war into webapps/ and restart Tomcat; I cover both. First configure Tomcat manager user.

1. Edit tomcat-users.xml (Tomcat 9)

Path example:

C:\Users\<user>\apache-tomcat-9.0.112\apache-tomcat-9.0.112\conf\tomcat-users.xml


Add (inside <tomcat-users>):

<role rolename="manager-gui"/>
<role rolename="manager-script"/>
<role rolename="admin-gui"/>
<user username="jenkins" password="StrongPassword123" roles="manager-gui,manager-script"/>


Save file.

Security note: Use a strong password and never expose Tomcat manager to the public internet. For lab keep it local.

Restart Tomcat: shutdown.bat then startup.bat. Verify you can log into Tomcat manager at:

http://localhost:<port>/manager/html


(using jenkins / StrongPassword123). Screenshot successful login.

D. Install Jenkins plugin: “Deploy to container”

Jenkins → Manage Jenkins → Manage Plugins → Available → search Deploy to Container Plugin → Install and restart Jenkins.

Also ensure Git plugin and Pipeline plugins are installed (most Jenkins have them).

E. Add Tomcat credentials in Jenkins

Jenkins → Credentials → System → Global credentials (unrestricted) → Add Credentials:

Kind: Username with password

Username: jenkins

Password: StrongPassword123

ID (optional): tomcat-jenkins

Description: Tomcat manager credentials

Save. (Screenshot credentials entry—do not reveal password in submission; mask it if required.)

F. (Option 1) Automate deployment using Freestyle job post-build action

This is quick and useful to verify automatic deploy before converting to pipeline.

Open SE-Build job → Configure → Post-build Actions → Add Deploy war to container.

WAR/EAR files: **/target/event-app.war

Context path: /event-app (or leave blank to auto use war name)

Containers → Add → Tomcat 9.x Remote → URL: http://localhost:<tomcat-port>/ e.g. http://localhost:8082/
Credentials: select tomcat-jenkins

Save → Build Now.

Watch console log: it should show Copying war to container and success. Screenshot console showing deployment.

Verify in browser:

http://localhost:<port>/event-app/


Screenshot the app homepage and advanced page (index.jsp or registration page).

G. (Preferred) Create a Jenkins Pipeline (Jenkinsfile) — recommended final solution
1. Jenkinsfile content (Declarative)

Save this file as Jenkinsfile in your repo root (commit to main). It will be used by Jenkins Pipeline job.

pipeline {
  agent any
  tools {
    maven 'Maven-3.9'   // EXACT name configured in Manage Jenkins -> Global Tool Configuration
  }
  environment {
    TOMCAT_URL = 'http://localhost:8082'     // change to your Tomcat 9 port
    TOMCAT_CRED = 'tomcat-jenkins'           // Jenkins credential ID for Tomcat
  }
  stages {

    stage('Checkout') {
      steps {
        checkout([$class: 'GitSCM', branches: [[name: '*/main']], userRemoteConfigs: [[url: 'https://github.com/rayyanahmed26042005/SE.git']]])
      }
    }

    stage('Build') {
      steps {
        sh 'mvn -B clean package'          // on Linux agent
        // Use bat on Windows agent:
        // bat 'mvn -B clean package'
      }
      post {
        success {
          archiveArtifacts artifacts: '**/target/*.war', fingerprint: true
        }
      }
    }

    stage('Deploy to Tomcat') {
      steps {
        script {
          // Use Deploy to container plugin by calling its step
          deploy adapters: [tomcat9(credentialsId: "${env.TOMCAT_CRED}", url: "${env.TOMCAT_URL}")], contextPath: '/event-app', war: '**/target/*.war'
        }
      }
    }
  }

  post {
    success {
      echo 'Pipeline completed successfully.'
    }
    failure {
      echo 'Pipeline failed.'
    }
  }
}


Important:

If your Jenkins agent is Windows, replace sh with bat commands.

Make sure the tool name (Maven-3.9) exactly matches Jenkins Configure Tools.

2. Create Pipeline job in Jenkins

Jenkins → New Item → SE-Pipeline → Pipeline → OK.

In Pipeline → Definition: Pipeline script from SCM → SCM: Git → Repository URL.

Branch: */main. Script Path: Jenkinsfile.

Save → Build Now. Watch stage view. Each stage should go green in Stage View. Screenshot pipeline stage view and console log.

If Deploy fails (common reasons):

Invalid Tomcat URL or credentials.

Tomcat manager not accessible.

Context path already in use — check manager or webapps folder.
Troubleshoot by opening Jenkins console log and Tomcat manager logs (catalina.out).

H. Pipeline View & Proof of web app running (deliverables)

Take screenshots of:

Jenkins pipeline stage view (all stages green).

Console output showing mvn package and deploy success.

Tomcat Manager web UI showing deployed application (/event-app).

Browser screenshot of http://localhost:<port>/event-app/ with visible app.

Jenkins job workspace showing target/event-app.war.

Also export Jenkins job config if required (job config.xml).

Q1 — Troubleshooting checklist (common issues)

404 after deploy: ensure you deployed to the Tomcat instance that’s actually running and on the port you use in the URL. Confirm Tomcat version and port in server.xml.

403 Manager denied: your tomcat user lacks manager-script role. Edit tomcat-users.xml and restart Tomcat.

Plugin deploy step errors: plugin not installed or used wrong deploy adapter (Tomcat 9 adapter for Tomcat 9).

Maven build fails: check pom.xml, dependencies, and Java version compatibility; run mvn -e -X clean package locally to see verbose errors.

Jenkins agent PATH issues: make sure Maven and Java are configured under Manage Jenkins → Global Tool Configuration, or use full paths in the script ("C:\\Program Files\\apache-maven-3.9.9\\bin\\mvn.cmd").

Q2 — UML Design (StarUML) — precise steps

Goal: produce a Class Diagram for Library Management System.

A. Create the diagram in StarUML

Install StarUML (or use any UML tool). Open StarUML → New Project → Select Class Diagram.

Add classes and attributes/methods as below.

B. Required classes (with attributes & methods)

1. Book

Attributes:

+bookId: String

+title: String

+author: String

+isbn: String

+available: boolean

Methods:

+isAvailable(): boolean

+setAvailability(status: boolean): void

2. Member

Attributes:

+memberId: String

+name: String

+email: String

+phone: String

Methods:

+borrowBook(book: Book): Loan

+returnBook(loan: Loan): boolean

+getBorrowedBooks(): List<Book>

3. Librarian

Attributes:

+librarianId: String

+name: String

Methods:

+issueBook(member: Member, book: Book): Loan

+receiveBook(loan: Loan): boolean

4. Loan (Transaction)

Attributes:

+loanId: String

+book: Book

+member: Member

+issueDate: Date

+dueDate: Date

+returnDate: Date

+fine: double

Methods:

+calculateFine(currentDate: Date): double

+isOverdue(currentDate: Date): boolean

5. (Optional) Catalog / Inventory

Manage collections and search.

C. Relationships and multiplicity

Member 1 --- * Loan (A member can have many loans)

Book 1 --- * Loan (A book may participate in many loans over time)

Loan aggregates Member and Book (association)

Librarian 1 --- * Loan (Librarian issues many loans) — or Librarian operates on Loan (dependency)

Set multiplicities explicitly:

Member (1) — (0..*) Loan

Book (1) — (0..*) Loan

Librarian (1) — (0..*) Loan

D. Visibility, notes, and export

Use + for public, - for private.

Add a note with constraints: “Fine = (daysLate × ratePerDay)”

Export PNG or JPEG: File → Export Diagram → choose image.

E. Screenshots required

Final diagram exported as PNG (screenshot).

Also include a short text summary listing classes — paste in report.

Q3 — Webhooks to trigger Jenkins builds

Assumption: Jenkins is reachable at http://<your-host>:8080/ from GitHub (if GitHub is remote, use public/NGROK IP or GitHub Actions runner). For a local-only environment you can use ngrok or set webhook on GitHub enterprise if host is accessible.

A. Option 1 — Local Jenkins on public IP (recommended for production)

If your Jenkins is accessible from the internet (public IP), you can use the direct URL.

B. Option 2 — Local dev using ngrok (if Jenkins is local and not public)

Download ngrok and run:

ngrok http 8080


Note the https://xxxxx.ngrok.io forwarding URL. Use that in GitHub webhook.

C. Configure Jenkins to accept GitHub webhooks

Jenkins → Manage Jenkins → Configure Global Security → Check “Enable CSRF protection” (default).

Install plugin: GitHub plugin and GitHub Integration Plugin and GitHub Hook Plugin.

Jenkins → Credentials → add GitHub token (if private repo triggers needed). For public repo, webhook is enough.

D. Create webhook in GitHub

Go to your repo → Settings → Webhooks → Add webhook.

Payload URL:

http(s)://<jenkins-host>:8080/github-webhook/


or if using ngrok:

https://xxxxx.ngrok.io/github-webhook/


Content type: application/json

Secret: optional (recommended). If you set a secret, configure Jenkins GitHub plugin to use the same secret.

Which events: choose Just the push event.

Add webhook. GitHub will send a test ping. Screenshot the webhook config and the ping success.

E. Configure Jenkins job to be triggered by GitHub

For a Freestyle job: In job config → Build Triggers → Check GitHub hook trigger for GITScm polling.

For Pipeline job: In job config (if Pipeline script from SCM) also enable GitHub hook trigger for GITScm polling.

Save.

F. Test webhook

Make a small change in repository (e.g., edit README.md) → commit & push.

Go to Jenkins → Build Queue or Job → a build should start automatically.

Screenshot: GitHub webhook delivery (shows 200 status) and Jenkins console output showing build started due to webhook.

Troubleshooting:

If webhook shows red, check Jenkins Manage Webhooks logs or GitHub delivery logs for response code and payload. Common cause: Jenkins not reachable, missing path, or CSRF settings.

Q4 — Create an EC2 Instance with Ubuntu and Deploy Application (detailed)

This section assumes you have an AWS account and can create resources (or use free tier).

A. Create AWS EC2 Instance (Ubuntu)

Login AWS console → EC2 → Launch Instance.

Choose AMI: Ubuntu Server 22.04 LTS (HVM), SSD Volume Type.

Choose instance type: t2.micro (free tier eligible).

Key pair: Create new key pair or use existing (download .pem). Save securely.

Network settings: Create or choose security group:

inbound rules:

SSH (TCP 22) from your IP

HTTP (TCP 80) from anywhere (0.0.0.0/0)

If you map container port to 8080 on the host, add 8080 as well.

Launch instance, note Public IPv4 address.

B. SSH into EC2

From your local machine (Linux/macOS) run:

chmod 400 mykey.pem
ssh -i mykey.pem ubuntu@<EC2_PUBLIC_IP>


On Windows use PuTTY or WSL.

C. Install Docker & Java (choose approach)

Option 1: Build WAR on EC2 using Maven and run in Tomcat or Tomcat image.
Option 2 (cleanest): Use Docker + Tomcat image and COPY WAR.

Install Docker:
sudo apt update
sudo apt install -y docker.io git
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu   # logout/login for group change or use sudo for docker commands

Install Maven (if building on EC2):
sudo apt install -y maven
mvn -v

D. Clone repo on EC2
git clone https://github.com/rayyanahmed26042005/SE.git
cd SE

E. Build the WAR (if building on EC2)
mvn clean package
ls target/event-app.war


If you built the WAR on Jenkins instead and want to use that artifact, you can scp it from Jenkins host to EC2:

scp -i mykey.pem C:\path\to\event-app.war ubuntu@<EC2_PUBLIC_IP>:/home/ubuntu/


(Windows scp via Git Bash or use WinSCP.)

F. Create Dockerfile and build container

In repo root on EC2, create Dockerfile:

# Using Tomcat 9 JVM image
FROM tomcat:9.0-jdk17-temurin
# Remove examples and default ROOT (optional)
RUN rm -rf /usr/local/tomcat/webapps/ROOT
# Copy WAR into Tomcat webapps
COPY target/event-app.war /usr/local/tomcat/webapps/event-app.war
EXPOSE 8080


Build and run:

docker build -t eventapp:latest .
docker run -d --name eventapp -p 80:8080 eventapp:latest


Now open in browser:

http://<EC2_PUBLIC_IP>/event-app/


Screenshot the app running.

G. Alternative: Run Tomcat container and mount WAR
docker run -d --name eventapp -p 80:8080 -v /home/ubuntu/event-app.war:/usr/local/tomcat/webapps/event-app.war tomcat:9

H. Persist & logs

To view logs: docker logs -f eventapp

Stop: docker stop eventapp

Remove: docker rm eventapp

Final deliverables to capture for submission (screenshots + files)

For each item include timestamped screenshots and brief captions.

For Q1 (Jenkins/Tomcat)

Jenkins job config (SE-Build) showing SCM and build step.

Jenkins console output showing mvn clean package success.

Jenkins workspace showing target/event-app.war.

Tomcat Manager UI showing /event-app deployed.

Browser screenshot of http://localhost:<port>/event-app/ (app working).

Jenkins pipeline stage view (if pipeline used) with green stages.

Jenkinsfile contents screenshot or file included.

tomcat-users.xml snippet showing manager-script/manager-gui user (mask password if needed).

For Q2 (UML)

StarUML Class Diagram PNG export.

Short description (text) of classes and relationships.

For Q3 (Webhook)

GitHub webhook configuration (payload URL / event).

Webhook delivery success (200) screenshot.

Jenkins job triggered automatically console log showing build started due to webhook.

For Q4 (EC2 & Docker)

EC2 instance details page (instance id, public IP).

Security group inbound rules screenshot.

SSH terminal showing docker run and docker ps.

Browser screenshot http://<EC2_PUBLIC_IP>/event-app/.

Extra: Useful commands & quick reference
Jenkins

Restart Jenkins: http://localhost:8080/restart (admin only)

Jenkins CLI: java -jar jenkins-cli.jar -s http://localhost:8080/ ...

Tomcat

Start: bin/startup.bat or bin/startup.sh

Stop: bin/shutdown.bat or bin/shutdown.sh

Main logs: logs/catalina.out (Linux) or logs\catalina.*.log (Windows)

Manager HTML path: /manager/html (for GUI), /manager/text for script API.

Maven

Build: mvn clean package

Run tests: mvn test

Run with full debug: mvn -X clean package

Docker

Build: docker build -t eventapp .

Run: docker run -d -p 80:8080 eventapp

Logs: docker logs -f eventapp

Marks-to-evidence mapping (to make grading easy)

Q1 (25): Provide Jenkinsfile, pipeline screenshots, Tomcat deployed app screenshots, build logs.

Q2 (25): StarUML exported class diagram and explanation.

Q3 (25): GitHub webhook setup screenshots + Jenkins console showing auto-trigger.

Q4 (25): EC2 instance info, Dockerfile, docker run & public IP working screenshot.

Common pitfalls & proactive tips

Tomcat version mismatch: Always use Tomcat 9 for Javax based JSP/servlets. Tomcat 10/11 require namespace migration. Confirm in Tomcat home page footer.

Port confusion: Confirm Tomcat’s Connector port in conf/server.xml. If multiple Tomcats exist, only one will answer on a port.

Jenkins tool names: The tools { maven 'Maven-3.9' } must match the name under Manage Jenkins → Global Tool Configuration exactly.

Credentials in Jenkins: Use credentials id reliably and keep manager-script role in Tomcat tomcat-users.xml.

Webhook reachability: For local Jenkins behind NAT, use ngrok for testing webhooks.

AWS charges: Even free tier can charge if you exceed limits. Stop/terminate EC2 when done.

Ready-to-copy artifacts

Jenkinsfile (already above) — copy to repo root.

Dockerfile (already above) — put into repo root for EC2 Docker build.

Tomcat user snippet (already above) — add to tomcat-users.xml.
