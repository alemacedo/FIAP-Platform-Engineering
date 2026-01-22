#!/bin/bash
set -e
echo "Iniciando instalação do nginx..."
yum update -y
yum install -y nginx
systemctl start nginx
systemctl enable nginx

# Criar página customizada com informações do ambiente
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
      <p><strong>Ambiente:</strong> ${workspace}</p>
      <p><strong>Instância:</strong> nginx-${workspace}-${count_index}</p>
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
echo "Nginx instalado e iniciado com sucesso!"
