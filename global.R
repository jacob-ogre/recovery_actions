# Global functions to be called at app initiation.
# Copyright (c) 2016 Defenders of Wildlife, jmalcom@defenders.org

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


system("touch restart.txt", intern = FALSE)

#############################################################################
# Load packages and source files
#############################################################################
# library(DBI)
library(plyr)

library(DT)
library(dplyr)
library(highcharter)
library(shiny)
library(shinydashboard)
library(shinyBS)
library(tm)
library(wordcloud)

# library(leaflet)
# library(maptools)
# library(sp)

# source("data_mgmt/make_dataframes.R")
# source("data_mgmt/summary_fx.R")
# source("plot/bargraphs.R")
source("txt/help.R")
source("txt/metadata.R")
source("txt/notes.R")
source("txt/text_styles.R")

#############################################################################
# Load the data and basic data prep
#############################################################################
# This should be df 'full':
load("data/ROAR_05May2016.RData")

plan_list <- sort(unique(full$plan_title))
plan_list <- c("All", plan_list)

spp_list <- sort(unique(unlist(unlist(full$action_species))))
spp_list <- c("All", spp_list)

work_list <- sort(unique(unlist(unlist(full$work_types))))
work_list <- c("All", work_list)

ESO_list <- sort(unique(full$plan_lead_office))
ESO_list <- c("All", ESO_list)

act_priority_list <- sort(unique(full$action_priority))
act_priority_list <- c("All", act_priority_list)

priority_num_list <- sort(unique(full$action_priority_number))
priority_num_list <- c("All", priority_num_list)

lead_agency_list <- sort(unique(unlist(unlist(full$action_lead_agencies))))
lead_agency_list <- c("All", lead_agency_list)

responsible_list <- sort(unique(unlist(unlist(full$responsible_parties))))
responsible_list <- c("All", responsible_list)

status_list <- sort(unique(full$action_status))
status_list <- c("All", status_list)

full$action_prior_num <- ifelse(full$action_priority == "Other",
                                3,
                                ifelse(full$action_priority == "Prevent significant decline or habitat loss", 2, 1))

#############################################################################
# update colors for CSS
validColors_2 <- c("red", "yellow", "aqua", "blue", "light-blue", "green",
                   "navy", "teal", "olive", "lime", "orange", "orange_d", "fuchsia",
                   "purple", "maroon", "black")

validateColor_2 <- function(color) {
    if (color %in% validColors_2) {
        return(TRUE)
    }
  
    stop("Invalid color: ", color, ". Valid colors are: ",
         paste(validColors_2, collapse = ", "), ".")
}


