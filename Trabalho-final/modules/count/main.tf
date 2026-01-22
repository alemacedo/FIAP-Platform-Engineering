# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

variable "project" {
  default = "fiap-lab"
}

data "aws_vpc" "vpc" {
  tags = {
    Name = "${var.project}"
  }
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = ["${data.aws_vpc.vpc.id}"]
  }
}




resource "aws_elb" "web" {
  name = "elb-${terraform.workspace}"

  subnets         = data.aws_subnets.all.ids
  security_groups = ["${aws_security_group.allow-ssh.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 6
  }

  # The instances are registered automatically
  instances = aws_instance.web.*.id
}

resource "aws_instance" "web" {
  instance_type = "t3.micro"
  ami           = "${lookup(var.aws_amis, var.aws_region)}"

  count = var.instances_count

  subnet_id              = data.aws_subnets.all.ids[count.index % length(data.aws_subnets.all.ids)]
  vpc_security_group_ids = ["${aws_security_group.allow-ssh.id}"]
  key_name               = "${var.KEY_NAME}"

  # User data para instalar e iniciar nginx
  user_data = base64encode(<<-EOF
#!/bin/bash
set -e

echo "=== Atualizando sistema ==="
yum update -y

echo "=== Instalando nginx via amazon-linux-extras ==="
amazon-linux-extras install nginx1 -y

echo "=== Iniciando nginx ==="
systemctl start nginx
systemctl enable nginx

echo "=== Criando página HTML personalizada ==="
cat > /usr/share/nginx/html/index.html <<'HTML'
<!DOCTYPE html>
<html>
<head>
  <title>Trabalho Final - Platform Engineering</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 40px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; }
    .container { background: rgba(0,0,0,0.7); padding: 30px; border-radius: 10px; max-width: 600px; margin: 0 auto; }
    h1 { color: #4ade80; }
    .info { background: rgba(255,255,255,0.1); padding: 15px; margin: 10px 0; border-radius: 5px; }
  </style>
</head>
<body>
  <div class="container">
    <h1>✅ Trabalho Final - Platform Engineering</h1>
    <div class="info">
      <p><strong>Ambiente:</strong> ${terraform.workspace}</p>
      <p><strong>Instância:</strong> nginx-${terraform.workspace}-${count.index}</p>
      <p><strong>IP Privado:</strong> <span id="private-ip">Carregando...</span></p>
      <p><strong>Timestamp:</strong> <span id="timestamp">Carregando...</span></p>
    </div>
    <p>✨ Nginx está rodando com sucesso!</p>
  </div>
  <script>
    fetch('http://169.254.169.254/latest/meta-data/local-ipv4')
      .then(r => r.text())
      .then(ip => document.getElementById('private-ip').textContent = ip)
      .catch(() => document.getElementById('private-ip').textContent = 'Indisponível');
    document.getElementById('timestamp').textContent = new Date().toLocaleString('pt-BR');
  </script>
</body>
</html>
HTML

systemctl reload nginx
echo "=== Nginx instalado e iniciado com sucesso! ==="
EOF
  )

  tags = {
    Name = "nginx-${terraform.workspace}-${count.index}"
  }
}
