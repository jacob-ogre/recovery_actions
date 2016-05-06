# Import ROAR data to RData.
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
# 

library(readxl)

file <- "data/ROAR_05May2016.xlsx"
data <- read_excel(file)

dim(data)
names(data)

for(i in 1:length(data)) {
    cat(paste0("Variable: ", names(data)[i], "\n"))
    cat(paste0("Class: ", class(data[[i]]), "\n"))
    cat("====================\n")
}

head(data$action_species)
spp <- strsplit(data$action_species, split = ", ")
data$action_species <- spp

resp <- strsplit(data$resonsible_parties, split = ", ")
data$resonsible_parties <- resp

data$work_types <- strsplit(data$work_types, split = ", ")
data$labor_types <- strsplit(data$labor_types, split = ", ")
data$action_lead_agencies <- strsplit(data$action_lead_agencies, split = ", ")

names(data)[13] <- "responsible_parties"
names(data)[3] <- "action_priority_number"

full <- data

save(full, file="data/ROAR_05May2016.RData")

