# Generic server-side code for the SE_Candidates app.
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

# source("server_pages/server_species_page.R")
# source("server_pages/server_chart_page.R")
# source("server_pages/server_alt_map_page.R")
# source("data_mgmt/get_gbif.R")

#############################################################################
# Define the server with calls for data subsetting and making figures
#############################################################################
shinyServer(function(input, output, session) {

    ######################################################################
    # Some basic functions
    output$defenders <- renderImage({
        width <- session$clientData$output_defenders_width
        if (width > 100) {
            width <- 100
        }
        list(src = "www/01_DOW_LOGO_COLOR_300.png",
             contentType = "image/png",
             alt = "Defenders of Wildlife",
             width=width)
    }, deleteFile=FALSE)

    sub_df <- reactive({
        cur_sub <- full
        if(input$plan_in != "All") {
            cur_sub <- cur_sub[grep(x = cur_sub$plan_title,
                                    pattern = input$plan_in, fixed=T), ]
        }
        if(input$spp_in != "All") {
            cur_sub <- cur_sub[grep(x = cur_sub$action_species,
                                    pattern = input$spp_in, fixed=T), ]
        }
        if(input$work_in != "All") {
            cur_sub <- cur_sub[grep(x = cur_sub$work_types,
                                    pattern = input$work_in, fixed=T), ]
        }
        if(input$ESO_in != "All") {
            cur_sub <- cur_sub[grep(x = cur_sub$plan_lead_office,
                                    pattern = input$ESO_in, fixed=T), ]
        }
        if(input$agency_in != "All") {
            cur_sub <- cur_sub[grep(x = cur_sub$action_lead_agencies, 
                                    pattern = input$agency_in, fixed=T), ]
        }
        if(input$responsible_in != "All") {
            cur_sub <- cur_sub[grep(x = cur_sub$responsible_parties, 
                                    pattern = input$responsible_in, fixed=T), ]
        }
        if(input$status_in != "All") {
            cur_sub <- cur_sub[grep(x = cur_sub$action_status, 
                                    pattern = input$status_in, fixed=T), ]
        }
        if(input$actprior_in != "All") {
            cur_sub <- cur_sub[grep(x = cur_sub$action_priority, 
                                    pattern = input$actprior_in, fixed=T), ]
        }
        cur_sub
    })

    output$n_actions <- renderText({
        dim(sub_df())[1]
    })

    output$n_species <- renderText({
        length(unique(unlist(unlist(sub_df()$action_species))))
    })

    output$n_plans <- renderText({
        length(unique(sub_df()$plan_title))
    })

    output$n_work_type <- renderText({
        length(unique(unlist(unlist(sub_df()$work_types))))
    })

    output$work_plot <- renderPlotly({
        work_cnts <- sort(table(unlist(unlist(sub_df()$work_types))), 
                          decreasing=TRUE)
        cur_df <- data.frame(x = names(work_cnts), y = as.vector(work_cnts))
        cur_df$x <- factor(cur_df$x, 
                           levels = cur_df$x[order(-cur_df$y)])
        if(length(cur_df$x) > 20) {
            cur_df <- head(cur_df, 20)
        }

        plt <- ggplot(data = cur_df, aes(x, y)) +
               geom_bar(stat = "identity", fill = "#0A4783") +
               labs(x = "", y = "\nNumber actions\n") +
               theme(axis.text.x=element_text(angle=45,hjust=1,vjust=0.5)) +
               theme_pander()

        ggplotly(plt)
    })

    output$status_plot <- renderPlotly({
        stat_cnts <- sort(table(sub_df()$action_status), decreasing=TRUE)
        cur_df <- data.frame(x = names(stat_cnts), y = as.vector(stat_cnts))
        cur_df$x <- factor(cur_df$x, 
                           levels = cur_df$x[order(-cur_df$y)])

        plt <- ggplot(data = cur_df, aes(x, y)) +
               geom_bar(stat = "identity", fill = "#0A4783") +
               labs(x = "", y = "\n# actions\n") +
               theme(axis.text.x=element_text(angle=45,hjust=1,vjust=0.5)) +
               theme_pander()

        ggplotly(plt)
    })

    output$desc_cloud <- renderPlot({
        if(length(sub_df()$action_description) > 1000) {
            subsamp <- sample(sub_df()$action_description, 1000)
        } else {
            subsamp <- sub_df()$action_description
        }
        w1 <- gsub("\\,|\\.|\\)|\\(", "", x = subsamp)
        w2 <- paste(w1, collapse = " ")
        res <- wordcloud(w2, 
                         random.color = FALSE,
                         rot.per = 0,
                         scale = c(3, 0.3),
                         asp = 2,
                         min.freq = 5,
                         max.words = 100,
                         colors = c("lightsteelblue4", "black", "darkorange1"))
        return(res)
    })

    output$the_data <- renderDataTable({
      the_dat <- sub_df()
      DT::datatable(the_dat,         
            rownames=FALSE,
            filter="top", 
            extensions="ColVis", 
            options = list(dom = 'C<"clear">lfrtip',
                           pageLength = 25))
    })

    # gvisLineChart(dat,
    #     xvar = "year",
    #     yvar = c("threats", "demography"),
    #     options = list(legend = "{position:'top'}",
    #                    vAxis = "{title:'Score', minValue:'-1', maxValue:'1'}",
    #                    hAxis = "{title:'Year'}",
    #                    height = 300,
    #                    dataOpacity = 0.3,
    #                    pointSize = 9,
    #                    lineWidth = 2,
    #                    chartArea="{bottom: 20, left: 100, width:'80%', height:'70%'}"
    #               ) 
    #     )


})