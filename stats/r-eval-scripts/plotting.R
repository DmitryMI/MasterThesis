plot_default <- function(data_table, y_id, param1_values, param2_values, y_label = NULL, unit_name = NULL, x_label = "Number of Drones"){
  print("Drawing...")
  
  y_name = deparse(substitute(y_id))
  param1_name = names(param1_values)[1]
  print(stringr::str_interp("Plot-splitting param: ${param1_name}"))
  param2_name = names(param2_values)[1]
  print(stringr::str_interp("Multiline param: ${param2_name}"))
  
  style_param <- sym(param2_name)
  # map <- aes(x = NumberOfDrones, y = {{ y_id }}, color = {{ style_param }})
  map <- aes(x = NumberOfDrones, y = {{ y_id }}, linetype = as.factor({{ style_param }}), shape = as.factor({{ style_param }}))
  
  for(i in 1:nrow(param1_values)){
    param1_value <- param1_values[i,]
    query_slice1 = stringr::str_interp("select * from data_table where ${param1_name} == ${param1_value}")
    data_slice1 <- sqldf(query_slice1)
    
    plot_name <- stringr::str_interp("${param1_name} = ${param1_value}")
    
    multiline_plot <- NULL
    for(j in 1:nrow(param2_values)){
      param2_value <- param2_values[j,]
      query_slice2 = stringr::str_interp("select * from data_slice1 where ${param2_name} == ${param2_value}")
      data_slice2 <- sqldf(query_slice2)
      if (is.null(multiline_plot)){
        multiline_plot <- ggplot(data = data_slice2, mapping = map) + geom_line() + geom_point() + ggtitle(plot_name) +
          scale_linetype_discrete(name = param2_name) + scale_shape_discrete(name = param2_name)
      }
      else{
        multiline_plot <- multiline_plot + geom_line(data = data_slice2) + geom_point(data = data_slice2)
      }

      if (!is.null(y_label))
      {
        y_label_value <- y_label
        if (!is.null(unit_name))
        {
          y_label_value <- paste(y_label_value, " [", unit_name, "]", sep="")
        }
        multiline_plot <- multiline_plot + xlab(x_label) + ylab(y_label_value)
      }
    }
    
    plot(multiline_plot, main=plot_name)
  }
  
  
}

