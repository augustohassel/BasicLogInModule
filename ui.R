# SHINY UI ####
# Aplicacion ####
dashboardPagePlus(
    skin = "black",
    title = "Basic LogIn", 
    # enable_preloader = TRUE,
    sidebar_fullCollapse = T,
    # TITULO --------------------
    header = dashboardHeaderPlus(
        title = "Basic LogIn", 
        userOutput("menu_user")
    ),
    # BARRA LATERAL--------------------
    sidebar = dashboardSidebar(
        useShinyjs(),
        useSweetAlert(),
        sidebarMenuOutput("menu")
    ),
    # CONTENIDO--------------------
    body =  dashboardBody(
        login_ui("login"),
        # CONTENIDO TABS--------------------
        tabItems(
            
            # 1 - Personal > Personal Activo --------------------
            tabItem(tabName = "first_page",
                    hidden(div(id="first_page_show", ## ATENCION
                               fluidRow(
                                   h1(HTML("Bienvenido!!! Más info en <a href = 'https://www.hasselpunk.com' target = '_blank'>hasselpunk</a>!!!"), align = "center")
                               )
                    )) ## ATENCION
            ) # cierra el tab
            
        )# cierra tabitems
    )# cierra el body del dashboard
)# cierra el dashboard page