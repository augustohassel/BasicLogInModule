#' UI: Login
#'
#' @param id 
login_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    uiOutput(ns("modal_login"))
  )
  
}

#' Server: Login
#'
#' @param input 
#' @param output 
#' @param session 
#' @param usuarios_full 
#' @param usuarios_validos
#'
#' @return Alerta de creacion o error
login <- function(input, output, session, usuarios_full, usuarios_validos) {
  
  ns <- session$ns
  
  full_users <- usuarios_full
  valid_users <- usuarios_validos
  
  return_values <- shiny::reactiveValues()
  
  output$modal_login <- renderUI({
    showModal(
      modalDialog(
        title = NULL,
        easyClose = F,
        size = "s", 
        fade = F, 
        footer = tagList( 
          prettySwitch(inputId = ns("recuperar"), label = HTML("Recuperar Contrase&ntilde;a"), status = "danger", fill = TRUE)
        ),
        textInput(ns("usuario"), label = tagList(icon("user"), "Usuario"), width = "100%"),
        passwordInput(ns("password"), label = tagList(icon("lock"), HTML("Contrase&ntilde;a")), width = "100%"),
        div(actionButton(ns("login"), "Ingresar", icon = icon("sign-in-alt"), style="background-color:forestgreen; color:white"), align="right")
      )
    )
  })
  
  observeEvent(input$recuperar, {
    if (input$recuperar == T) {
      showModal(
        modalDialog(
          title = NULL,
          easyClose = F,
          size = "s", 
          fade = F, 
          footer = tagList(
            actionButton(ns("cancel"), "Cancelar", icon = icon("window-close"), style="background-color:indianred; color:white"), 
            actionButton(ns("reset"), "Reset", icon = icon("envelope"), style="background-color:cadetblue; color:white")
          ),
          textInput(ns("usuario_reset"), label = tagList(icon("user"), "Usuario"), width = "100%")
        )
      )
    } 
    
  })
  
  observeEvent(input$cancel, {
    session$reload()
  })
  
  observeEvent(input$reset, {
    
    shinyjs::disable("reset")
    
    if (input$usuario_reset == '') {
      sendSweetAlert(session = session, title = "Mmm...", text = "Debe seleccionar un usuario!", type = "warning")
    } else if (full_users() %>% filter(UserName == input$usuario_reset) %>% nrow() == 0) {
      sendSweetAlert(session = session, title = "Mmm...", text = "El usuario no existe!", type = "warning")
    } else if (full_users() %>% filter(UserName == input$usuario_reset) %>% pull(EMail) %>% is.na()) {
      sendSweetAlert(session = session, title = "Sin correo asociado", text = HTML("Solicite al administrador que le asocie un correo al usuario para recibir el mail de reseteo de la contrase&ntilde;a"), type = "warning", html = T)
    } else {
      removeModal()
      sendSweetAlert(session = session, title =  "EMail Enviado!", text = HTML("Se ha enviado un correo para resetear la contrase&ntilde;a. Por favor, cierre este sitio e intente nuevamente con la nueva contrase&ntilde;a generada."), type = "success", html = T, closeOnClickOutside = F)
    }
    
    shinyjs::enable("reset")
    
  })
  
  observeEvent(input$login, {
    
    shinyjs::disable("login")
    
    if (input$usuario=="") {
      sendSweetAlert(session = session, title = "Mmm...", text = "Debe colcar un usuario para acceder!", type = "warning")
    } else if (full_users() %>% filter(UserName == input$usuario) %>% nrow() == 0) {
      sendSweetAlert(session = session, title = "Mmm...", text = "El usuario no existe!", type = "warning")
    } else if (valid_users() %>% filter(UserName == input$usuario) %>% nrow() == 0) {
      sendSweetAlert(session = session, title = "Mmm...", text = "El usuario no posee acceso a este tablero!", type = "warning")
    } else if (valid_users() %>% filter(UserName == input$usuario) %>% pull(Password) %>% is.na()) {
      sendSweetAlert(session = session, title = "Mmm...", text = HTML("Debe setear una contrase&ntilde;a, hable con el admin!"), type = "warning", html = T)
    } else {
      pass_ok <- identical(valid_users() %>% filter(UserName==input$usuario) %>% pull(Password), digest::digest(object = input$password, algo = "sha1", serialize = F))
      
      if (pass_ok) {
        sendSweetAlert(session = session, title = "Bienvenido!", type = "success")
        
        return_values$user <- valid_users() %>% filter(UserName==input$usuario) %>% pull(UserId)
        return_values$person <- valid_users() %>% filter(UserName==input$usuario) %>% pull(PersonaId)
        return_values$permiso <- valid_users() %>% filter(UserName==input$usuario) %>% pull(Permiso)
        
        removeModal()
        
      } else if (!pass_ok) {
        sendSweetAlert(session = session, title = "Error!", text = HTML("Contrase&ntilde;a Incorrecta"), type = "error", html = T)
      }
    }
    
    shinyjs::enable("login")
    
    
  })
  
  return(return_values)
}