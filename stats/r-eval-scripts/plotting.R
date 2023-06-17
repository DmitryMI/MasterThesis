plot_drone_height <- function(data_table, y_id, y_label = NULL, unit_name = NULL, x_label = "Drones Altitude Minimum [m]"){
  map <- aes(x = DroneHeightMin, y = {{ y_id }}, shape = "circle")

  panel_background <- element_blank()
  axis_line = element_line(colour = "black")
  panel_grid_major = element_blank()
  panel_grid_minor = element_blank()
  
  theme <- theme(
    panel.background = panel_background,
    legend.position = "none",
    axis.line = axis_line,
    panel.grid.major = panel_grid_major, panel.grid.minor = panel_grid_minor
  )
  
  singleline_plot <- ggplot(data = data_table, mapping = map) + geom_line() + geom_point() + theme
  
  if (!is.null(y_label))
  {
    y_label_value <- y_label
    if (!is.null(unit_name))
    {
      y_label_value <- paste(y_label_value, " [", unit_name, "]", sep="")
    }
    singleline_plot <- singleline_plot + xlab(x_label) + ylab(y_label_value)
  }
  
  plot(singleline_plot)
}

plot_default <- function(data_table, y_id, param1_values, param2_values, y_label = NULL, unit_name = NULL, x_label = "Number of Drones", y_limits = NULL, legend_position = c(0.8, 0.2)){
  print("Drawing...")
  point_size <- 3
  
  y_name = deparse(substitute(y_id))
  param1_name = names(param1_values)[1]
  print(stringr::str_interp("Plot-splitting param: ${param1_name}"))
  param2_name = names(param2_values)[1]
  print(stringr::str_interp("Multiline param: ${param2_name}"))
  
  style_param <- sym(param2_name)
  
  param2_vec <- param2_values[, 1]
  print(param2_vec)
  
  # map <- aes(x = NumberOfDrones, y = {{ y_id }}, color = {{ style_param }})
  map <- aes(x = NumberOfDrones, y = {{ y_id }}, linetype = as.factor({{style_param}}), shape = as.factor({{style_param}}))
  
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
        
        # legend_background <- element_rect(fill=alpha("lightblue", 0.3), size=0.2, linetype="solid", colour ="darkblue")
        legend_background <- element_blank()
        panel_background <- element_blank()
        axis_line = element_line(colour = "black")
        panel_grid_major = element_blank()
        panel_grid_minor = element_blank()
        
        theme <- theme(
          legend.position = legend_position,
          legend.background = legend_background,
          panel.background = panel_background,
          axis.line = axis_line,
          panel.grid.major = panel_grid_major, panel.grid.minor = panel_grid_minor
          )
        
        multiline_plot <- ggplot(data = data_slice2, mapping = map) + geom_line() + geom_point(size = point_size) +
          scale_linetype_discrete(name = param2_name, breaks = param2_vec) + scale_shape_discrete(name = param2_name, breaks = param2_vec) + theme
        multiline_plot <- multiline_plot + expand_limits(x = 0, y = 0)
        multiline_plot <- multiline_plot + scale_x_discrete(limits = c(0, 25, 50, 75, 100))
        if(! is.null(y_limits))
        {
          multiline_plot <- multiline_plot + scale_y_discrete(limits = y_limits)
        }
      }
      else{
        multiline_plot <- multiline_plot + geom_line(data = data_slice2) + geom_point(data = data_slice2, size = point_size)
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
    
    plot(multiline_plot)
  }
  
  
}

