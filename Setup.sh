#!/bin/bash

# ===========================================
#   🚀 Infraestrutura Local - Setup
# ===========================================

echo "=========================================="
echo "   🚀 Infraestrutura Local - Setup"
echo "=========================================="
echo ""

# ===========================================
# 📁 CRIAÇÃO DA ESTRUTURA
# ===========================================

# Pega o diretório onde o script está
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Cria pasta do projeto
BASE_DIR="$SCRIPT_DIR/infra-local"
mkdir -p "$BASE_DIR"

echo "📁 Criando estrutura em: $BASE_DIR"

# Pastas do GitLab
mkdir -p "$BASE_DIR/gitlab/config"
mkdir -p "$BASE_DIR/gitlab/logs"
mkdir -p "$BASE_DIR/gitlab/data"

# Pasta do MinIO
mkdir -p "$BASE_DIR/minio/data"

echo "✅ Pastas criadas!"

# ===========================================
# 📄 CRIAÇÃO DO DOCKER-COMPOSE
# ===========================================

echo "📄 Criando docker-compose.yml..."

cat > "$BASE_DIR/docker-compose.yml" << 'EOF'
services:
  # GitLab
  gitlab:
    image: gitlab/gitlab-ce:latest
    container_name: gitlab
    hostname: gitlab.local
    restart: unless-stopped
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://localhost:9602'
        gitlab_rails['initial_root_password'] = 'MJrdYhDGMh32R5TW'
        puma['worker_processes'] = 3
        sidekiq['concurrency'] = 10
        prometheus_monitoring['enable'] = false
        gitlab_rails['gitlab_shell_ssh_port'] = 2222
        gitlab_rails['time_zone'] = 'America/Sao_Paulo'
        registry['enable'] = false
    ports:
      - "9602:9602"
      - "2222:22"
    volumes:
      - ./gitlab/config:/etc/gitlab
      - ./gitlab/logs:/var/log/gitlab
      - ./gitlab/data:/var/opt/gitlab
    shm_size: '512m'
    networks:
      - infra-network

  # MinIO
  minio:
    image: minio/minio:latest
    container_name: minio
    restart: unless-stopped
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: admin
      MINIO_ROOT_PASSWORD: MJrdYhDGMh32R5TW
    ports:
      - "9000:9000"
      - "9601:9001"
    volumes:
      - ./minio/data:/data
    networks:
      - infra-network

networks:
  infra-network:
    driver: bridge
    name: infra-local-network
EOF

echo "✅ docker-compose.yml criado!"

# ===========================================
# 📄 CRIAÇÃO DO JSON DE CREDENCIAIS
# ===========================================

echo "📄 Criando credenciais.json..."

cat > "$BASE_DIR/credenciais.json" << 'EOF'
{
  "gitlab": {
    "url": "http://localhost:9602",
    "user": "root",
    "password": "MJrdYhDGMh32R5TW",
    "ssh_port": 2222
  },
  "minio": {
    "console": "http://localhost:9601",
    "api": "http://localhost:9000",
    "user": "admin",
    "password": "MJrdYhDGMh32R5TW"
  },
  "jenkins": {
    "url": "http://localhost:9600",
    "nota": "instalado local"
  }
}
EOF

echo "✅ credenciais.json criado!"

# ===========================================
# 📄 CRIAÇÃO DO README
# ===========================================

echo "📄 Criando README.md..."

cat > "$BASE_DIR/README.md" << 'EOF'
# Infraestrutura Local

## 📁 Estrutura

```
infra-local/
├── docker-compose.yml
├── credenciais.json
├── README.md
├── gitlab/
│   ├── config/
│   ├── logs/
│   └── data/
└── minio/
    └── data/
```

## 🌐 Portas

| Serviço       | Porta |
|---------------|-------|
| Jenkins       | 9600  |
| MinIO Console | 9601  |
| MinIO API     | 9000  |
| GitLab        | 9602  |
| GitLab SSH    | 2222  |

## 🔑 Credenciais

| Serviço | Usuário | Senha            |
|---------|---------|------------------|
| GitLab  | root    | MJrdYhDGMh32R5TW |
| MinIO   | admin   | MJrdYhDGMh32R5TW |

## 🚀 Comandos

```bash
# Subir
docker compose up -d

# Parar
docker compose down

# Logs
docker compose logs -f
```
EOF

echo "✅ README.md criado!"

# ===========================================
# ✅ FINALIZAÇÃO
# ===========================================

echo ""
echo "=========================================="
echo "✅ Setup concluído!"
echo "=========================================="
echo ""
echo "📁 Tudo criado em: $BASE_DIR"
echo ""
echo "🚀 Para subir:"
echo "   cd $BASE_DIR"
echo "   docker compose up -d"
echo ""
echo "📋 Acessos:"
echo "   GitLab:  http://localhost:9602 (root / MJrdYhDGMh32R5TW)"
echo "   MinIO:   http://localhost:9601 (admin / MJrdYhDGMh32R5TW)"
echo "   Jenkins: http://localhost:9600 (local)"
