# Zebra Control (v0.1)

O **Zebra Control** é um conjunto de utilitários em PowerShell e Batch Script projetado para facilitar o gerenciamento, controle e calibração de impressoras térmicas Zebra (focado nos modelos ZD220, ZD230 e ZD421) diretamente pela rede local. 

Utilizando a porta TCP 9100, os scripts enviam comandos ZPL (Zebra Programming Language) nativos para executar ações no hardware da impressora.

## 🚀 Funcionalidades

- **Controle do Painel Frontal (Botão FEED):** Desabilite ou habilite o botão físico da impressora para evitar avanço acidental ou indevido de etiquetas pelos usuários.
- **Calibração de Mídia Remota:** Envie comandos para forçar a impressora a se auto-calibrar remotamente, resolvendo problemas de salto de etiquetas.
- **Bloqueio de Reset de Fábrica (ZD421):** Previne que configurações sejam perdidas bloqueando o comando de hard reset (3ª piscada do botão FEED).
- **Persistência de Configurações:** Escolha se as alterações de painel serão temporárias (apenas na RAM, resetando ao desligar) ou gravadas na NVRAM permanentemente.

## 📁 Estrutura do Projeto

- `ZEBRA_230_control.ps1` / `.bat`: Scripts interativos com menu para controlar as impressoras (foco padrão).
- `ZEBRA_421_control.ps1`: Script interativo otimizado para o modelo ZD421, com opções avançadas de controle de Reset.
- `Calibrar_Impressora.bat`: Script de execução direta (silencioso) para calibração rápida de um IP fixo configurado no arquivo.
- Manuais Oficiais e Procedimentos Internos para consulta.

## 🛠️ Como Utilizar

1. Faça o download do repositório.
2. Certifique-se de que o seu computador e a impressora estejam na mesma rede, e que a impressora possua um endereço IP acessível (Porta TCP 9100 liberada).
3. Execute o script desejado (ex: `ZEBRA_230_control.ps1`). *Recomendado abrir o PowerShell ou CMD, não requer instalação.*
4. Siga as instruções do menu na tela e informe o endereço IP quando solicitado.

## 📞 Suporte e Contato

Caso necessite de suporte, tenha dúvidas ou queira sugerir melhorias, entre em contato:

- **Email:** gabriel.pestrini@unimedribeirao.com.br
- **Instagram:** [@gpestrini](https://instagram.com/gpestrini)
