# SERVER ####

source(file="global.R")

# Aplicacion ####

function(input, output, session) {
    # Reconectar
    session$allowReconnect(TRUE)
    
    # 0.1 - Variables Globales --------------------
    
    global_id_persona <- shiny::reactiveVal(NULL) # persona logueada
    global_id_usuario_dashboard <- shiny::reactiveVal(NULL) # usuario logueado
    global_select_in_table <- shiny::reactiveVal(NULL)
    
    # traigo los usuarios validos con sus contraseñas
    usuarios_full <- reactive({
        
        data <- data.frame(UserId = c(1L, 2L, 3L),
                           UserName = c("demo", "juan", "pedro"), 
                           Password = c("89e495e7941cf9e40e6980d14a16bf023ccd4c91", "b49a5780a99ea81284fc0746a78f84a30e4d5c73", "4410d99cefe57ec2c2cdbd3f1d5cf862bb4fb6f8"), 
                           Permiso = c(1L, 0L, 1L), 
                           PersonaId = c(1L, 2L, 3L), 
                           Nombre = c("Demo", "Juan", "Pedro"), 
                           stringsAsFactors = F)
        return(data)
    })
    
    # filtro los usuarios que tienen permisos para acceder al tablero
    usuarios_validos <- reactive({
        data <- usuarios_full()
        
        data <- data %>% 
            filter(Permiso %in% c(1))
        
        return(data)
    })
    
    # 0.2.1 - LogIn --------------------
    
    # observer para log in 
    
    login_result <- callModule(module = login, 
                               id = "login", 
                               usuarios_full = usuarios_full, 
                               usuarios_validos = usuarios_validos)
    
    observe({
        req(!is_null(login_result$permiso))
        req(!is_null(login_result$person))
        req(!is_null(login_result$user))
        
        if (login_result$permiso %in% c(1)) { # permiso total
            # menu
            output$menu <- renderMenu({
                sidebarMenu(
                    menuItem(text = "Tab", tabName = "first_page", icon = icon("skull"))
                )
            })
            
            # accesos
            shinyjs::hide("login_page", anim = T, animType = "slide")
            shinyjs::show("first_page_show") # paginas
            
        } 
        
        global_id_persona(login_result$person)
        global_id_usuario_dashboard(login_result$user)
        
    })
    
    # 0.2.2 - Logout --------------------
    
    observeEvent(input$logout, {
        session$reload()
    }, ignoreNULL = T)
    
    # 0.3 - Datos Usuario --------------------
    
    global_usuario <- reactive({
        data <- usuarios_full() %>%
            filter(PersonaId == global_id_persona())
        return(data)
    })
    
    # 0.4 - Menu Usuario --------------------
    output$menu_user <- renderUser({
        
        if (!is.null(global_id_persona())) {
            dashboardUser(
                name = global_usuario()$Nombre,
                src = "https://pbs.twimg.com/profile_images/520068842978942976/CcM51OI8_400x400.jpeg",
                footer = div(actionBttn(inputId = "logout", label = "Salir", style = "unite", color = "danger", size = "xs"), align = "center")
            )
        } else {
            NULL
        }
        
    })
}