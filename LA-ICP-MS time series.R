# vtepma/LA-ICP-MS time series is licensed under The MIT License
# Copyright 2026 Lowell R. Moore

# Path to working directory (e.g. contining time series data and this script)
dir_in_global <- "C:/Users/Your Name/where you put your data..."

# ------------------------------------
# Functions
# ------------------------------------

# Open file selected with GUI menu as dataframe "Import"
new_file <- function(dir_in = dir_in_global){
  file_i <<- list.files(dir_in)[menu(choices = list.files(dir_in), graphics = TRUE)]
  path_in <- file.path(dir_in, file_i)
  Import <- read.csv(path_in, skip = 3)
  Import <<- Import[-nrow(Import),]
  print(file_i)
}

# Plot time series data for all elements, and select signal and background
#   intervals using system GUI.  This function may only work on Windows,
#   but this can probably be fixed by replacing "windows()" in the first line 
run_plot <- function(){
  windows()
  xs <<- as.numeric(Import$Time..Sec.)
  plot(0, 0, type = "n", log = "y"
       , ylim = c(1, max(as.numeric(as.matrix(Import[,2:ncol(Import)]))))
       , xlim = c(0, max(as.numeric(Import[,1])))
       , xlab = "Time, s", ylab = "Counts")
  
  # Plot all elements
  plot_cols <- hcl.colors(ncol(Import)-1, palette = "Hawaii")
  for(i in 2:ncol(Import)){
    print(colnames(Import)[i])
    ys <- as.numeric(Import[,i])
    lines(xs, ys, lwd = 1, col = plot_cols[i-1])
  }
  click_coords <- locator(n = 6)
  cutoffs <<- click_coords$x
  abline(v = cutoffs)
  Sys.sleep(2)
  dev.off()
}

# Extract data using regions selected in "run_plot" function, calculate
#   signal-noise ratios (above detection or bdl?), and return net count rates
extract_data <- function(){
  save_out <- file_i
  flag_BGL <- which((xs > cutoffs[1]) & (xs < cutoffs[2]))
  flag_plateau <- which((xs > cutoffs[3]) & (xs < cutoffs[4]))
  flag_BGU <- which((xs > cutoffs[5]) & (xs < cutoffs[6]))
  for(i in 2:ncol(Import)){
    ys <- as.numeric(Import[,i])
    mean_BGL <- mean(ys[flag_BGL])
    mean_plateau <- mean(ys[flag_plateau])
    mean_BGU <- mean(ys[flag_BGU])
    net_i <- mean_plateau - mean(c(mean_BGL, mean_BGU))
    
    sd_BG <- sd(c(ys[flag_BGL], ys[flag_BGU]), na.rm = TRUE)
    sd_plateau <- sd(ys[flag_plateau])
    snr_i <- net_i/sd_BG
    if(snr_i < 3){net_i <- "b.d.l."}
    
    save_out <- c(save_out, net_i)
    log_info <- paste("Mass =", colnames(Import)[i], "SNR =", round(snr_i, 1))
    #print(log_info)
  }
  return(save_out)
}

# ------------------------------------
# Initialize
# ------------------------------------

# Run this block to generate an output dataframe using one of the time series
#   text files as a template.  Also supresses system beep triggered by "locator"
#   function.
new_file()
output_df <- Import[1,]; colnames(output_df)[1] <- "File"; output_df[1,] <- NA
save_out <- file_i
options(locatorBell = FALSE)

# ------------------------------------
# Run
# ------------------------------------

# Run this block once per time series text file
new_file()
run_plot()
new_row <- extract_data()
output_df <- rbind.data.frame(output_df, new_row)
print(new_row)
print(output_df$File)
# Optional code to remove a row in the event that you screw something up
if(FALSE){output_df <- output_df[-1,]}

# ------------------------------------
# Saving
# ------------------------------------

# Run this block to save the output dataframe to .csv, and then go calculate
#  compositions in Excel (or whatever) using the method described by
#  Longerich et al (1996; JAAS)
path_out <- paste(dir_in_global, "output.csv", sep = "/")
write.csv(x = output_df, file = path_out, quote = FALSE, row.names = FALSE)
