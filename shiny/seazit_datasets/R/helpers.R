list_low_freq_tb <- function(d) {
  map(d, function(x) {
    r1 <- rle(sort(x))
    ind <- which(r1$lengths == min(r1$lengths))
    if (length(ind) == length(r1$lengths)) { #all same occurence
      return(NULL)
    } else {
      return(r1$values[ind])
    }
  })
}


with_tooltip <- function(value, tooltip) {
  tags$abbr(style = "text-decoration: underline; text-decoration-style: dotted; cursor: help",
            title = tooltip, value)
}

min_max_aggregate <- function() {
  JS("
  function calculateMinMaxV(values, rows) {
    let minV = Infinity;
    let maxV = -Infinity;

  rows.forEach(function(row, index) {
    const currentV = values[index];

    if (currentV < minV) {
      minV = currentV;
    }

    if (currentV > maxV) {
      maxV = currentV;
    }
  });

  return `[${minV}], [${maxV}]`;
  }")
}

color_ontolgy_table <- function(lab_name, border = NULL) {

  JS(
    paste0(
      "function(rowInfo) {
        var value = rowInfo.row['", lab_name, "']
        if (value  !=  null) {
          var background = '#FAFAD2'
        } else {
          var background = '#FFFFFF'
        }
        if('", border, "' == 'yes') {
          return { background: background, borderRight: '2px solid rgba(0, 0, 0, 0.1)' }
        } else {
          return { background: background }
        }

        }"
    )
  )
}

# do not know how to make it work
# color_low_freq <- function(value, index, col_name, l) {
#   if (value %in% l[[col_name]]) {
#     color <- "red"
#   } else {
#     color <- "black"
#   }
#   return(color)
# }


