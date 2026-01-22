# ✅ Checklist de Validação - Trabalho Final Platform Engineering

**Data de Verificação:** 21 de janeiro de 2026  
**Status:** ✅ **COMPLETO E TESTADO**

---

## 1. Estrutura de Pastas

- ✅ `Trabalho-final/` existe com subpasta `modules/count`
- ✅ Arquivo raiz: `main.tf` (chama o módulo)
- ✅ Arquivo raiz: `state.tf` (backend S3)
- ✅ Módulo: `modules/count/main.tf` (recursos EC2, ELB, SG)
- ✅ Módulo: `modules/count/variables.tf` (declarações de variáveis)
- ✅ Módulo: `modules/count/outputs.tf` (saídas)
- ✅ Módulo: `modules/count/securitygroup.tf` (Security Group)

---

## 2. Transformação em Módulo e Variável de Contagem

### 2.1 Declaração de Variável
- ✅ `modules/count/variables.tf` declara:
  ```terraform
  variable "instances_count" {
    type        = number
    description = "Number of instances to create"
    validation {
      condition     = var.instances_count >= 1
      error_message = "instances_count must be at least 1"
    }
  }
  ```

### 2.2 Uso no Recurso
- ✅ `modules/count/main.tf` usa `count = var.instances_count` na EC2

### 2.3 Chamada do Módulo na Raiz
- ✅ `main.tf` chama:
  ```terraform
  module "app_server" {
    source          = "./modules/count"
    instances_count = 2
  }
  ```

---

## 3. Nomes Dinâmicos com Workspaces

### 3.1 EC2 Tag Name
- ✅ Formato: `Name = "nginx-${terraform.workspace}-${count.index}"`
  - **DEV:** `nginx-dev-0`, `nginx-dev-1`
  - **PROD:** `nginx-prod-0`, `nginx-prod-1`

### 3.2 ELB Name
- ✅ Formato: `name = "elb-${terraform.workspace}"`
  - **DEV:** `elb-dev`
  - **PROD:** `elb-prod`

### 3.3 Security Group
- ✅ Formato name: `name = "allow-ssh-${terraform.workspace}"`
- ✅ Formato tag Name: `Name = "allow-ssh-${terraform.workspace}"`
  - **DEV:** `allow-ssh-dev`
  - **PROD:** `allow-ssh-prod`

---

## 4. Estado Remoto (Backend S3)

- ✅ `state.tf` configurado com:
  ```terraform
  backend "s3" {
    bucket = "teste-rafbarbo-12356"
    key    = "trabalho-final/terraform.tfstate"
    region = "us-east-1"
  }
  ```
- ✅ **Key única:** `trabalho-final/terraform.tfstate` (evita conflitos com laboratórios anteriores)

---

## 5. Workspaces Criados e Validados

| Workspace | Status | Recursos Criados | Nomes dos Recursos |
|-----------|--------|------------------|--------------------|
| **dev** | ✅ Ativo | 2 EC2 + 1 ELB + 1 SG | `nginx-dev-[0,1]`, `elb-dev`, `allow-ssh-dev` |
| **prod** | ✅ Ativo | 2 EC2 + 1 ELB + 1 SG | `nginx-prod-[0,1]`, `elb-prod`, `allow-ssh-prod` |

### 5.1 Instâncias EC2 em Execução
```
nginx-dev-0  | running | ec2-3-239-189-69.compute-1.amazonaws.com
nginx-dev-1  | running | ec2-44-197-178-36.compute-1.amazonaws.com
nginx-prod-0 | running | ec2-34-230-55-143.compute-1.amazonaws.com
nginx-prod-1 | running | ec2-34-204-78-160.compute-1.amazonaws.com
```

---

## 6. Alterações Aplicadas

### 6.1 Correções Realizadas

1. **Nomes dinâmicos com `terraform.workspace`**
   - EC2 Tag `Name`: alterado de `nginx-%03d` para `nginx-${terraform.workspace}-${count.index}`
   - SG `name` e tag `Name`: alterados de `allow-ssh` para `allow-ssh-${terraform.workspace}`

2. **Backend S3 Key**
   - Alterado de `trabalho-final/terraform.state` para `trabalho-final/terraform.tfstate`

3. **Variável `instances_count`**
   - Adicionadas: `description` e `validation` (mínimo 1 instância)

4. **Provisioners SSH**
   - Comentados (arquivo de chave não existe em todas as máquinas)
   - Mantém a lógica de demonstração dos workspaces

5. **Filtro de Subnets**
   - Removida restrição por tag `Tier=Public`
   - Usa todas as subnets disponíveis da VPC

---

## 7. Limpeza para Entrega

### ⚠️ **ANTES DE ZIPAR, EXECUTE:**

```bash
cd Trabalho-final
rm -rf .terraform
rm .terraform.lock.hcl
zip -r trabalho-final.zip .
```

**Tamanho esperado sem `.terraform`:** ~50KB (vs 793MB com)

---

## 8. Fluxo de Execução Validado

```bash
# Inicializar (feito)
terraform init

# Criar e aplicar dev (✅ feito)
terraform workspace new dev
terraform apply

# Criar e aplicar prod (✅ feito)
terraform workspace new prod
terraform apply

# Listar workspaces (✅ validado)
terraform workspace list
# Output: default, dev*, prod

# Destruir (quando necessário)
terraform workspace select dev
terraform destroy -auto-approve
terraform workspace select prod
terraform destroy -auto-approve
```

---

## 9. Validação Final

- ✅ Terraform valida sem erros (`terraform validate`)
- ✅ Backend S3 configurado e acessível
- ✅ Ambientes DEV e PROD isolados em workspaces separados
- ✅ Nomes dinâmicos com `terraform.workspace` funcionam corretamente
- ✅ Módulo `count` reutilizável com variável de contagem
- ✅ Estrutura pronta para entrega

---

## 📝 Notas Finais

Este trabalho demonstra:
1. **Modularização**: Uso de módulos locais (`./modules/count`)
2. **Contagem dinâmica**: Variável `instances_count` controla número de recursos
3. **Múltiplos ambientes**: Workspaces `dev` e `prod` isolados automaticamente
4. **Nomes únicos**: Concatenação com `${terraform.workspace}` evita colisões
5. **Estado remoto**: Backend S3 com chave específica para evitar corrupção

**Status para entrega:** ✅ **PRONTO**

---

*Último update: 21/01/2026 - Teste executado com sucesso*
