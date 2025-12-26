# 🚀 Infraestrutura Local de Desenvolvimento

Ambiente completo de CI/CD local com GitLab, MinIO e integração com Kubernetes.

## 📋 Visão Geral

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Jenkins   │────▶│   GitLab    │────▶│   Docker    │────▶│ Kubernetes  │
│ :9600       │     │ :9602       │     │   Build     │     │   Local     │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │    MinIO    │
                    │ :9000/:9601 │
                    └─────────────┘
```

## 🛠️ Componentes

| Serviço | Porta | Descrição |
|---------|-------|-----------|
| **GitLab CE** | 9602 | Repositório Git e CI/CD |
| **MinIO Console** | 9601 | Interface web do storage S3 |
| **MinIO API** | 9000 | API compatível com S3 |
| **Jenkins** | 9600 | Servidor de automação (instalação local) |

## 📦 Pré-requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) com Kubernetes habilitado
- 8GB+ de RAM disponível (recomendado 16GB+)
- 20GB+ de espaço em disco
- Jenkins instalado localmente (opcional)

## 🚀 Instalação

### 1. Clone o repositório

```bash
git clone https://github.com/seu-usuario/infra-local.git
cd infra-local
```

### 2. Execute o script de setup

```bash
chmod +x setup.sh
./setup.sh
```

### 3. Inicie os serviços

```bash
cd infra-local
docker compose up -d
```

### 4. Aguarde a inicialização

O GitLab leva **5-10 minutos** na primeira execução. Acompanhe com:

```bash
docker logs -f gitlab
```

Quando aparecer `gitlab Reconfigured!`, está pronto!

## 🔐 Credenciais Padrão

Após a instalação, as credenciais são salvas em `credenciais.json`:

| Serviço | Usuário | Senha |
|---------|---------|-------|
| GitLab | `root` | *(ver credenciais.json)* |
| MinIO | `admin` | *(ver credenciais.json)* |

## 🌐 Acessando os Serviços

- **GitLab:** http://localhost:9602
- **MinIO Console:** http://localhost:9601
- **MinIO API:** http://localhost:9000

## ☸️ Configurando Kubernetes

### Habilitar Kubernetes no Docker Desktop

1. Abra Docker Desktop
2. Vá em **Settings** → **Kubernetes**
3. Marque **Enable Kubernetes**
4. Clique em **Apply & Restart**

### Verificar a instalação

```bash
kubectl cluster-info
kubectl get nodes
```

## 🔧 Integrando com Jenkins

### 1. Instale os plugins necessários

- Git Plugin
- GitLab Plugin
- Kubernetes Plugin
- Docker Pipeline

### 2. Configure as credenciais do GitLab

1. Jenkins → Manage Jenkins → Credentials
2. Add Credentials → Username with password
3. Use as credenciais do `credenciais.json`

### 3. Exemplo de Jenkinsfile

```groovy
pipeline {
    agent any
    
    environment {
        GITLAB_URL = 'http://localhost:9602'
        KUBECONFIG = credentials('kubeconfig')
    }
    
    stages {
        stage('Checkout') {
            steps {
                git url: "${GITLAB_URL}/root/meu-projeto.git",
                    credentialsId: 'gitlab-credentials'
            }
        }
        
        stage('Build') {
            steps {
                sh 'docker build -t minha-app:${BUILD_NUMBER} .'
            }
        }
        
        stage('Deploy to K8s') {
            steps {
                sh '''
                    kubectl apply -f k8s/deployment.yaml
                    kubectl set image deployment/minha-app \
                        minha-app=minha-app:${BUILD_NUMBER}
                '''
            }
        }
    }
}
```

## 📁 Estrutura do Projeto

```
infra-local/
├── docker-compose.yml    # Configuração dos containers
├── setup.sh              # Script de instalação
├── credenciais.json      # Credenciais de acesso
├── README.md             # Esta documentação
├── gitlab/
│   ├── config/           # Configurações do GitLab
│   ├── logs/             # Logs do GitLab
│   └── data/             # Dados do GitLab
└── minio/
    └── data/             # Dados do MinIO (buckets)
```

## 🔄 Comandos Úteis

### Gerenciamento dos containers

```bash
# Iniciar serviços
docker compose up -d

# Parar serviços
docker compose down

# Ver logs
docker compose logs -f

# Reiniciar um serviço específico
docker compose restart gitlab
```

### GitLab

```bash
# Acessar console do GitLab
docker exec -it gitlab gitlab-rails console

# Resetar senha do root
docker exec -it gitlab gitlab-rake "gitlab:password:reset[root]"

# Verificar status dos serviços
docker exec -it gitlab gitlab-ctl status
```

### MinIO

```bash
# Criar alias para o cliente MinIO
docker exec -it minio mc alias set local http://localhost:9000 admin SUA_SENHA

# Criar bucket
docker exec -it minio mc mb local/meu-bucket

# Listar buckets
docker exec -it minio mc ls local
```

### Kubernetes

```bash
# Ver pods
kubectl get pods -A

# Ver serviços
kubectl get svc -A

# Aplicar manifesto
kubectl apply -f deployment.yaml

# Ver logs de um pod
kubectl logs -f nome-do-pod
```

## 🐛 Troubleshooting

### GitLab não inicia

```bash
# Verificar logs
docker logs gitlab

# Recriar container
docker compose down
rm -rf gitlab/config/*
docker compose up -d
```

### Erro de memória

Aumente a memória do Docker Desktop:
- Settings → Resources → Memory → 8GB+

### Porta já em uso

```bash
# Verificar processo na porta (Windows)
netstat -ano | findstr :9602

# Verificar processo na porta (Linux/Mac)
lsof -i :9602

# Alterar porta no docker-compose.yml
```

### Kubernetes não conecta

```bash
# Verificar contexto
kubectl config current-context

# Deve mostrar: docker-desktop
```

## 📝 Variáveis de Ambiente

O `docker-compose.yml` aceita as seguintes variáveis:

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `GITLAB_HOME` | `./gitlab` | Diretório de dados do GitLab |
| `MINIO_ROOT_USER` | `admin` | Usuário admin do MinIO |
| `MINIO_ROOT_PASSWORD` | *(gerada)* | Senha do MinIO |

## 🤝 Contribuindo

1. Fork o projeto
2. Crie sua feature branch (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -m 'Add nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

⭐ Se este projeto te ajudou, considere dar uma estrela!
