Complete Step-by-Step Guide: Q2 → Q5
Q2: Maven Project Building – 30 Marks
1️⃣ Import Project into Eclipse

Option 1 (From Git):

File → Import → Git → Projects from Git (with smart import) → Next

Clone URI → Next

Enter URL: https://github.com/anujyog1/flightrepo.git

Select branch (main/master) → Next

Choose local directory → Finish

Option 2 (Local folder):

Git Bash:

git clone https://github.com/anujyog1/flightrepo.git


Eclipse: File → Open Projects from File System → Select flightrepo

2️⃣ Resolve Dependencies

Edit pom.xml file accordingly.

3️⃣ Build Maven Project

Right-click project → Run As → Maven build...

Enter goal: clean package

✅ WAR file is generated in target/LibraryRegistration.war.

Q3: Git and GitHub – 30 Marks
1️⃣ Initialize Git & Push
cd "C:\Users\Zeeshan\OneDrive\Desktop\Flight repo\flightrepo"

git init                 # Initialize repo
git add .                # Add all files
git commit -m "Initial commit"
git remote add origin https://github.com/yourusername/flightrepo.git
git branch -M main
git push -u origin main

2️⃣ Branching & Feature Work (SQB examples)

Create feature branch:

git checkout -b feature/search_flights_by_airline
git add .
git commit -m "Add flight search by airline"
git push -u origin feature/search_flights_by_airline


Merge main changes into feature branch:

git checkout main
git pull origin main
git checkout paymentintegration
git merge main


Resolve conflicts:

Edit conflicted files (e.g., login.jsp)

Then:

git add login.jsp
git commit -m "resolved conflicts"


Delete branch:

git branch -d search_flights_by_airline   # local
git push origin --delete search_flights_by_airline  # remote


Undo wrong commit but keep history clean:

git revert <commit-hash>
git push origin main


Clone repo for new developer:

git clone https://github.com/org/repo.git


View branches on remote:

git fetch --all
git branch -r


See last modifier of file:

git log -1 -- register.jsp


Show commit details:

git show          # last commit
git show <hash>   # specific commit

Q4: Docker – 20 Marks
1️⃣ Dockerfile (project root)
FROM tomcat:9.0

RUN rm -rf /usr/local/tomcat/webapps/ROOT
COPY target/LibraryRegistration.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]

2️⃣ Build Docker Image
docker build -t flightimage .

3️⃣ Run Container
docker run --name flightcontainer -d -p 8080:8080 flightimage


Access app: http://localhost:8080/

4️⃣ Push to Docker Hub
docker login
docker tag flightimage yourdockerhubusername/flightimage:latest
docker push yourdockerhubusername/flightimage:latest

5️⃣ Docker Useful Commands (SQB)
Action	Command
List containers	docker ps
Stop container	docker stop flightcontainer
Logs	docker logs flightcontainer
CPU/RAM usage	docker stats
Open shell inside container	docker exec -it flightcontainer /bin/bash
Delete image	docker rmi flightimage
Q5: Docker Compose – 10 Marks
1️⃣ docker-compose.yml (project root)
services:
  app:
    image: yourdockerhubusername/flightimage:latest
    container_name: tomcat-app
    ports:
      - "8081:8080"   # host 8081 → container 8080
    depends_on:
      - db
    environment:
      DB_HOST: db
      DB_PORT: 3306
      DB_NAME: mydb
      DB_USER: myuser
      DB_PASS: mypassword

  db:
    image: mysql:8.0
    container_name: mysql-db
    restart: always
    environment:
      MYSQL_DATABASE: mydb
      MYSQL_USER: myuser
      MYSQL_PASSWORD: mypassword
      MYSQL_ROOT_PASSWORD: rootpassword
    ports:
      - "3307:3306"  # host 3307 → container 3306
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:

2️⃣ Start Services
docker-compose up -d


App: http://localhost:8081/

MySQL: host localhost, port 3307, user myuser, password mypassword, database mydb

3️⃣ Verify / Logs / Stop
docker-compose ps
docker logs tomcat-app
docker logs mysql-db
docker-compose down -v


✅ Now your project is fully built, version-controlled, containerized, and running in a multi-container environment.
