# Projeto de Pedido

Este projeto é um sistema de controle de pedidos desenvolvido em Delphi, utilizando uma arquitetura em camadas para demonstração técnica.

## 🚀 Tecnologias e Arquitetura

Este projeto foi construído com as seguintes tecnologias e conceitos de arquitetura:

* **Linguagem de Programação:** Delphi (versão [colocar a versão do Delphi, ex: 11 Alexandria])
* **Banco de Dados:** SQLite
* **Framework de Acesso a Dados:** FireDAC
* **Arquitetura:** Aplicação em camadas, seguindo o padrão MVC (Model-View-Controller).
* **Princípios de Design:**
    * **Orientação a Objetos (OO):** Uso de classes para modelar as entidades (Cliente, Produto, Pedido, etc.).
    * **Orientação a Interface (OI):** As camadas se comunicam através de interfaces, o que garante baixo acoplamento e facilita a substituição de implementações.
    * **Clean Code:** Código limpo e de fácil manutenção, com separação clara de responsabilidades.
    * **Uso de SQL:** As operações de banco de dados são priorizadas usando SQL, conforme as melhores práticas para este tipo de desafio.

## 📁 Estrutura do Projeto

O projeto está organizado em três camadas principais:

### 1. **Model**
A camada de dados e lógica de negócio.
* `Projeto.Model.Conexao.pas`: Gerencia a conexão com o banco de dados (SQLite) usando FireDAC. Responsável por iniciar a conexão e criar a estrutura do banco se ela não existir.
* `Projeto.Model.DTO.Classes.pas`: Contém as classes DTOs (Data Transfer Objects), que representam as entidades do banco de dados (ex: `TDTOCliente`, `TDTOProduto`).
* `Projeto.Model.Interfaces.pas`: Define as interfaces para a camada de modelo (`iConexao`, `iQuerys`), permitindo que a camada de Controller dependa de abstrações, e não de implementações concretas.
* `Projeto.Model.Querys.pas`: Centraliza todas as operações SQL, garantindo que as consultas estejam em um único local, facilitando a manutenção e a reutilização.

### 2. **Controller**
A camada que orquestra a comunicação entre a View e o Model.
* `Projeto.Controller.Cliente.pas`: Lógica de negócio para a entidade Cliente.
* `Projeto.Controller.PedidoHeader.pas` / `Projeto.Controller.PedidoItem.pas`: Lógica de negócio para a gestão de pedidos e seus respectivos itens.
* `Projeto.Controller.Produto.pas`: Lógica de negócio para a entidade Produto.
* `Projeto.Controller.Interfaces.pas`: Define as interfaces que os Controllers implementam (ex: `iClienteController`), reforçando a orientação a interface.
* `Projeto.Controller.Fancy.Dialog.pas` / `Projeto.Controller.Loading.pas`: Classes de controle para componentes visuais reutilizáveis, como diálogos de notificação e telas de carregamento.

### 3. **View**
A camada de apresentação, responsável pela interface do usuário (UI).
* `Projeto.View.Principal.pas`: O formulário principal da aplicação.
* `Projeto.View.Cadastro.Cliente.pas`: Formulário de cadastro e consulta de clientes.
* `Projeto.View.Cadastro.Produto.pas`: Formulário de cadastro e consulta de produtos.
* `Projeto.View.Cadastro.Pedido.pas`: Formulário para criar, editar e visualizar pedidos.
* `Projeto.View.Consultas.pas`: Formulário genérico de consultas.
* `Projeto.View.Heranca.pas`: Contém uma classe base para formulários, utilizando o princípio de herança para evitar a repetição de código e padronizar a aparência e o comportamento das telas.

## 🛠️ Como Executar o Projeto
1.  Abra o arquivo `.dproj` no Delphi.
2.  Certifique-se de que o FireDAC está instalado e configurado corretamente.
3.  Compile o projeto. A aplicação irá criar o arquivo de banco de dados SQLite na primeira execução, se ele não existir.
4.  Execute a aplicação.

## ⚙️ Funcionalidades Implementadas
* Cadastro e edição de clientes.
* Cadastro e edição de produtos.
* Criação e gestão de pedidos de venda, com inclusão, edição e exclusão de itens.
* Visualização de pedidos realizados.

## ✒️ Autor

* **Abner dos Santos Rodrigues**
