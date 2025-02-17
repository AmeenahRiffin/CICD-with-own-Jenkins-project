resource "aws_instance" "sparta_app" {
    ami                    = var.ami
    instance_type          = var.app_instance_type
    key_name               = var.key_name
    vpc_security_group_ids = [aws_security_group.sparta_sg.id]
    associate_public_ip_address = true
    tags = {
    Name  = "sparta-${var.owner_name}-app"
    Owner = var.owner_name
    }
    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install -y nginx
                sudo apt install -y git
                curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
                sudo apt install -y nodejs
                curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
                export NVM_DIR="$HOME/.nvm"
                [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
                [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
                nvm install node
                sudo systemctl enable nginx
                sudo systemctl start nginx
                git clone https://github.com/AmeenahRiffin/tech501-sparta-app/
                mv tech501-sparta-app/* ./
                cd app
                npm install
                sudo npm install -g pm2
                pm2 start app.js
                EOF
}

resource "aws_instance" "jenkins_server" {
    ami                    = var.ami
    instance_type          = var.jenkins_instance_type
    key_name               = var.key_name
    vpc_security_group_ids = [aws_security_group.sparta_sg.id]
    associate_public_ip_address = true
    tags = {
    Name  = "sparta-${var.owner_name}-jenkins"
    Owner = var.owner_name
    }
    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install -y nginx
                curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
                sudo apt install -y nodejs
                sudo apt install -y openjdk-17-jdk
                wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc
                echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list
                sudo apt update -y
                sudo apt install -y jenkins
                sudo systemctl enable nginx
                sudo systemctl start nginx
                sudo systemctl enable jenkins
                sudo systemctl start jenkins
                EOF
}

output "sparta_app_public_ip" {
    description = "Public IP of Sparta App server"
    value       = aws_instance.sparta_app.public_ip
}

output "jenkins_server_public_ip" {
    description = "Public IP of Jenkins server"
    value       = aws_instance.jenkins_server.public_ip
}
