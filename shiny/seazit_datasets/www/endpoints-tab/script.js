$(document).on("click", "button.toggleIcons", function() {
  /* Update icons when dropdown is shown */
  if ($(this).parent().hasClass("open")) {
    /* Linked pickerInputs should be called id1 = "x_y" and id2 = "x" */
    var id1 = $(this).siblings("select").attr("id");
    var id2 = id1.split("_")[0];
    /* Loop over id1 dropdown elements */
    $("#" + id1)
    .siblings(".dropdown-menu")
    .find("ul.dropdown-menu.inner li")
    .each(function (index) {
      /* Get number of optgroup elements from id2 select */
      var n1 = $("#" + id2 + " :nth-child(" + (index + 1) + ")")
        .children()
        .length;
      /* Get number of selected optgroup elements from id2 dropdown */
      var n2 = $("#" + id2)
        .siblings(".dropdown-menu")
        .find("ul.dropdown-menu.inner li.optgroup-" + (index + 1) + ".selected")
        .length;
      /* n2 will be 0 if the dropdown hasn't been opened yet */
      var ok = n2 === 0 || n1 === n2;
      /* Output for debug */
      /*console.log([index, n1, n2, ok].join(" "));*/
      /* Update icon */
      $(this)
      .find("span.glyphicon")
      .toggleClass("glyphicon-ok", ok)
      .toggleClass("glyphicon-minus", !ok);
      /* Reset icon on click */
      $(this).off("click"); /* remove any previous listeners */
      $(this).click(function() {
        $(this)
        .find("span.glyphicon")
        .toggleClass("glyphicon-ok", true)
        .toggleClass("glyphicon-minus", false);
      });
    });
  }
});
