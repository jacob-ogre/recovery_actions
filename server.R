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
        if(input$priornum_in != "All") {
            cur_sub <- cur_sub[cur_sub$action_priority_number == input$priornum_in &
                               !is.na(cur_sub$action_priority_number), ]
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

    output$status_plot <- renderHighchart({
        hchart(sub_df()$action_status) %>% 
            hc_colors("#0A4783") %>%
            hc_title(text = "Status of recovery actions",
                     margin = 20, align = "left") %>%
            hc_legend(enabled = FALSE) %>%
            hc_yAxis(title = list(text = "# actions")) %>% 
            hc_exporting(enabled = TRUE)
    })

    output$work_plot <- renderHighchart({
        work_cnts <- sort(table(unlist(unlist(sub_df()$work_types))), 
                          decreasing=TRUE)
        cur_df <- data.frame(x = names(work_cnts), y = as.vector(work_cnts))
        cur_df$x <- factor(cur_df$x, 
                           levels = cur_df$x[order(-cur_df$y)])
        if(length(cur_df$x) > 20) {
            cur_df <- head(cur_df, 20)
        }

        highchart() %>%
            hc_xAxis(categories = cur_df$x) %>%
            hc_add_series(data = cur_df$y, type = "column") %>%
            hc_colors("#0A4783") %>%
            hc_title(text = "Distribution of work types",
                     margin = 20, align = "left") %>%
            hc_legend(enabled = FALSE) %>%
            hc_yAxis(title = list(text = "# actions"))
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
                         scale = c(6, 0.7),
                         asp = 2,
                         min.freq = 5,
                         max.words = 100,
                         colors = c("lightsteelblue4", "black", "darkorange1"))
        return(res)
    })

    output$lead_off_plot <- renderHighchart({
        ESO_cnts <- tapply(sub_df()$plan_title,
                           INDEX = sub_df()$plan_lead_office,
                           FUN = function(x) length(unique(x)))
        ESO_cnts <- sort(ESO_cnts, decreasing=TRUE)
        cur_df <- data.frame(x = names(ESO_cnts), y = as.vector(ESO_cnts))
        cur_df$x <- factor(cur_df$x, 
                           levels = cur_df$x[order(-cur_df$y)])
        if(length(cur_df$x) > 20) {
            cur_df <- head(cur_df, 20)
        }

        highchart() %>%
            hc_xAxis(categories = cur_df$x) %>%
            hc_add_series(data = cur_df$y, type = "column") %>%
            hc_colors("#0A4783") %>%
            hc_title(text = "Plans per Ecol. Serv. office (up to top 20)",
                     margin = 20, align = "left") %>%
            hc_legend(enabled = FALSE) %>%
            hc_yAxis(title = list(text = "# plans"))
    })

    output$prior_num_plot <- renderHighchart({
        cur_dat <- round(table(sub_df()$action_priority_number) /
                         length(sub_df()$action_priority_number), 3)
        cur_df <- data.frame(x = names(cur_dat), y = as.vector(cur_dat))
        highchart() %>%
            hc_add_series_labels_values(cur_df$x, cur_df$y, 
                                        colorByPoint = TRUE, 
                                        type = "pie") %>%
            hc_title(text = "Actions per priority number",
                     margin = 20, align = "left") %>%
            hc_legend(enabled = FALSE)
    })

    output$lead_ag_plot <- renderHighchart({
        cur_dat <- sort(table(unlist(unlist(sub_df()$action_lead_agencies))),
                        decreasing = TRUE)
        cur_df <- data.frame(x = names(cur_dat), y = as.vector(cur_dat))
        cur_df$x <- factor(cur_df$x, 
                           levels = cur_df$x[order(-cur_df$y)])
        if(length(cur_df$x) > 20) {
            cur_df <- head(cur_df, 20)
        }
        highchart() %>%
            hc_xAxis(categories = cur_df$x) %>%
            hc_add_series(data = cur_df$y, type = "column") %>%
            hc_colors("#0A4783") %>%
            hc_title(text = "Actions per lead agency (up to top 20 agencies)",
                     margin = 20, align = "left") %>%
            hc_legend(enabled = FALSE) %>%
            hc_yAxis(title = list(text = "# actions"))
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

})
