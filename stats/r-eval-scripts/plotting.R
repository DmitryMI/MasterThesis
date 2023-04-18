multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

plot_default <- function(received_div_jammed_table, param1_values, param2_values){
  print("Drawing...")

  param1_name = names(param1_values)[1]
  print(stringr::str_interp("Plot-splitting param: ${param1_name}"))
  param2_name = names(param2_values)[1]
  print(stringr::str_interp("Multiline param: ${param2_name}"))
  
  map <- aes(x = NumberOfDrones, y = ReceivedDivJammed, color = NumberOfVehicles)
  
  for(i in 1:nrow(param1_values)){
    param1_value <- param1_values[i,]
    query_slice1 = stringr::str_interp("select * from received_div_jammed_table where ${param1_name} == ${param1_value}")
    data_slice1 <- sqldf(query_slice1)
    
    multiline_plot <- NULL
    for(j in 1:nrow(param2_values)){
      param2_value <- param2_values[j,]
      query_slice2 = stringr::str_interp("select * from data_slice1 where ${param2_name} == ${param2_value}")
      data_slice2 <- sqldf(query_slice2)
      if (is.null(multiline_plot)){
        multiline_plot <- ggplot(data = data_slice2, mapping = map) + geom_line()
      }
      else{
        multiline_plot <- multiline_plot + geom_line(data = data_slice2)
      }
      
    }
    plot(multiline_plot)
  }
  
  
}

