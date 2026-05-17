#!/usr/bin/env Rscript

################################################
################################################
## LOAD LIBRARIES                             ##
################################################
################################################

library(plyr, quietly = TRUE, warn.conflicts = FALSE)
library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(tidyr, quietly = TRUE, warn.conflicts = FALSE)
library(stringr, quietly = TRUE, warn.conflicts = FALSE)
library(jsonlite, quietly = TRUE, warn.conflicts = FALSE)
library(writexl, quietly = TRUE, warn.conflicts = FALSE)

################################################
################################################
## DATA          ###############################
################################################
################################################

# PATHS
path <- getwd()
samples_ref <- read.table(paste0(path, "/chikungunya.txt"), header = F)

if (ncol(samples_ref) == 1) {
    colnames(samples_ref) <- c("id")
} else {
    colnames(samples_ref) <- c("id", "ref", "host")
}

# Fastq path

fastq_names <- list.files("../RAW/", pattern = "\\.fastq\\.gz$")
path_run <- Sys.readlink(paste0("../RAW/", fastq_names[1]))

# Host

kraken_script <- "05-kraken/_01_kraken_array.sbatch"
kraken_content <- readLines(kraken_script)
kraken_line <- kraken_content[grepl("--db", kraken_content)][1]
db_path <- str_extract(kraken_line, "(?<=--db )\\S+")
name_host <- tolower(basename(db_path))

# columnas
columnas <- "run\tuser\thost\tsample\ttotalreads\treadshostR1\treadshost\t%readshost\tNon-host-reads\t%Non-host-reads\tContigs\tLargest_contig"
name_columns <- as.vector(str_split(columnas, "\t", simplify = T))

list_assembly <- list(0)
for (i in 1:nrow(samples_ref)) {

    # Run, user, host and sequence
    name_run <- str_split(path_run, "/", simplify = T)[, 4]
    name_user <- str_split(path, "_", simplify = T)[, 3]
    date_service <- str_split(str_split(path, "_", simplify = T)[, 1], "/", simplify = T)[, 3]

    name_id <- as.character(samples_ref$id[i])

    # path outputfolder
    workdir <- "."

    # totalreads
    json_fastp <- fromJSON(paste0("02-preprocessing/", name_id, "/", name_id, "_fastp.json"))
    value_totalreads <- json_fastp$summary[["after_filtering"]]$total_reads

    # readshostR1
    table_kraken <- read.table(paste0("05-kraken/", name_id, "/", name_id, "_kraken.report"), sep = "\t")
    unclassified_reads <- as.numeric(subset(x = table_kraken, subset = V6 == "unclassified")[2])
    value_readhostr1 <- sum(table_kraken$V3)-unclassified_reads

    # readshosh
    value_readhost <- value_readhostr1 * 2

    # readshost
    value_percreadhost <- round((value_readhost * 100) / value_totalreads, 2)

    # non host reads
    value_nonhostreads <- value_totalreads - value_readhost

    # % non host
    value_percnonhostreads <- round((value_nonhostreads * 100) / value_totalreads, 2)

    # Contigs
    quast_report_path <- paste0("07-quast/", name_id, "/report.txt")

if (file.exists(quast_report_path)) {
    quast_lines <- readLines(quast_report_path)

    contigs_line <- quast_lines[grepl("^# contigs\\s", quast_lines) &
                                !grepl(">=", quast_lines)][1]
    value_contigs <- as.numeric(tail(str_split(trimws(contigs_line), "\\s+")[[1]], 1))

    lcontig_line <- quast_lines[grepl("^Largest contig", quast_lines)][1]
    value_lcontig <- as.numeric(tail(str_split(trimws(lcontig_line), "\\s+")[[1]], 1))


    if (length(value_contigs) == 0 || is.na(value_contigs)) value_contigs <- NA
    if (length(value_lcontig) == 0 || is.na(value_lcontig)) value_lcontig <- NA

} else {
    value_contigs <- NA
    value_lcontig <- NA
}

    # Create table
    list_assembly[[i]] <- c(name_run, name_user, name_host, name_id, value_totalreads, value_readhostr1, value_readhost, value_percreadhost, value_nonhostreads, value_percnonhostreads, value_contigs, value_lcontig)
}

df_final <- as.data.frame(do.call("rbind", list_assembly))
colnames(df_final) <- name_columns

# characters
columnas_ch <- as.vector(1:5)
df_final[, columnas_ch] <- apply(df_final[, columnas_ch], 2, function(x) as.character(x))

# numeric
columnas_nu <- as.vector(6:length(colnames(df_final)))
df_final[, columnas_nu] <- apply(df_final[, columnas_nu], 2, function(x) as.numeric(as.character(x)))

# group by sample
df_grouped <- df_final %>%
  group_by(sample) %>%
  summarise(
    run = first(run),
    user = first(user),
    host = first(host),


    totalreads = first(totalreads),
    readshostR1 = first(readshostR1),
    readshost = first(readshost),
    `%readshost` = first(`%readshost`),
    `Non-host-reads` = first(`Non-host-reads`),
    `%Non-host-reads` = first(`%Non-host-reads`),
    Contigs = if (all(is.na(Contigs))) NA else max(Contigs, na.rm = TRUE),
    Largest_contig = if (all(is.na(Largest_contig))) NA else max(Largest_contig, na.rm = TRUE),
    .groups = "drop"
  )

# Write table csv
write.table(df_grouped, "assembly_stats.csv", row.names = F, col.names = T, sep = "\t", quote = F)

# Write table xlsx
write_xlsx(df_grouped, "assembly_stats.xlsx", format_headers = F)
