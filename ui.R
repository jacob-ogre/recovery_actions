# Top-level UI organization for SE_Candidates app.
# Copyright (C) 2016 Defenders of Wildlife, jmalcom@defenders.org

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses/>.

#############################################################################
# Define the header and sidebar (disabled)
header <- dashboardHeader(disable = TRUE)
sidebar <- dashboardSidebar(disable = TRUE)

#############################################################################
# Define the page(s) with dashboardBody
body <- dashboardBody(
    tags$head(
        HTML("<link href='https://fonts.googleapis.com/css?family=Open+Sans:300,400' rel='stylesheet' type='text/css'>"),
        includeCSS("www/custom_styles.css")
    ),

    bsModal(id = "a_modal",
            title = "Title",
            trigger = "contrib",
            p("Text..."),
            size = "large"
    ),

    navbarPage("Recovery Actions",
        tabPanel(
            title="Recovery Actions",
            div(class="graph-outer",
                tags$head(
                    HTML("<link href='https://fonts.googleapis.com/css?family=Open+Sans:300,400' rel='stylesheet' type='text/css'>"),
                    includeCSS("www/custom_styles.css")
                ),
                tags$style(type="text/css", "body {padding-top:30px;}"),

                fluidRow(
                    column(12,
                        h1("Recovery Actions Explorer", 
                           style = "text-align: center; font-weight: bold;"),
                           hr()
                    )
                ),

                column(2,
                    absolutePanel(id="controls-graph", class="panel panel-default", 
                        fixed=FALSE, draggable=FALSE, top=0, left=10, 
                        right="auto", bottom="auto", width=230, height=NULL,

                        selectInput("plan_in",
                                    label = "Recovery Plan",
                                    choices = plan_list,
                                    width = "95%"
                        ),
                        selectInput("spp_in",
                                    label = "Species",
                                    choices = spp_list,
                                    width = "95%"
                        ),
                        selectInput("work_in",
                                    label = "Work Type",
                                    choices = work_list,
                                    width = "95%"
                        ),
                        selectInput("ESO_in",
                                    label = "Lead Office",
                                    choices = ESO_list,
                                    width = "95%"
                        ),
                        selectInput("agency_in",
                                    label = "Lead Agency",
                                    choices = lead_agency_list,
                                    width = "95%"
                        ),
                        selectInput("responsible_in",
                                    label = "Responsible Parties",
                                    choices = responsible_list,
                                    width = "95%"
                        ),
                        selectInput("status_in",
                                    label = "Action Status",
                                    choices = status_list,
                                    width = "95%"
                        ),
                        selectInput("actprior_in",
                                    label = "Action Priority",
                                    choices = act_priority_list,
                                    width = "95%"
                        ),
                        selectInput("priornum_in",
                                    label = "Action Priority Number",
                                    choices = act_priority_list,
                                    width = "95%"
                        )
                    )
                ),

                column(10,
                    fluidRow(
                        valueBox(
                            subtitle = "# recovery actions",
                            value = textOutput("n_actions"),
                            icon = icon("fa-list-ol"),
                            color = "olive",
                            width = 3
                        ),
                        valueBox(
                            subtitle = "# species",
                            value = textOutput("n_species"),
                            icon = icon("fa-list-ol"),
                            color = "orange",
                            width = 3
                        ),
                        valueBox(
                            subtitle = "# recovery plans",
                            value = textOutput("n_plans"),
                            icon = icon("fa-list-ol"),
                            color = "maroon",
                            width = 3
                        ),
                        valueBox(
                            subtitle = "# work types",
                            value = textOutput("n_work_type"),
                            icon = icon("fa-list-ol"),
                            color = "navy",
                            width = 3
                        )
                    ),
                    fluidRow(
                        column(6,
                            highchartOutput("status_plot", height = "500px")
                        ),
                        column(6,
                            highchartOutput("work_plot", height = "500px")
                        )
                    ),
                    fluidRow(hr()),
                    fluidRow(
                        column(6,
                            h4("(Up to) Top 100 words in actions"),
                            plotOutput("desc_cloud", height = "600px")
                        )
                    )
                ),

                fluidRow(
                    column(12,
                        br(),
                        hr(),
                        br()
                    ),
                    column(3),
                    column(6,
                        div(HTML(defenders_cc()), style=center_text)
                    ),
                    column(3)
                ),
                br(), br()
            )
        ),
        tabPanel(
            title="Data Table",
            tags$head(
                HTML("<link href='https://fonts.googleapis.com/css?family=Open+Sans:300,400' rel='stylesheet' type='text/css'>"),
                includeCSS("www/custom_styles.css")
            ),
            tags$style(type="text/css", "body {padding-top:30px;}"),
            fluidRow(
                div(style="overflow-x: scroll; background-color: #FFFFFF;
                           padding-left: 15px", 
                    column(12,
                        dataTableOutput("the_data")
                    )
                )
            )
        ),
        theme = "yeti.css",
        inverse = FALSE,
        position = "fixed-top"   
    )
)

dashboardPage(header, sidebar, body, skin = "blue")
