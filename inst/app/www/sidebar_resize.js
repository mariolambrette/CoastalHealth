$(document).on("shiny:connected", function() {
  function resizeMap() {
    var sidebarWidth = $("body").hasClass("sidebar-collapse") ? 0 : 350;
    var headerHeight = $(".main-header").outerHeight() || 50;
    $(".map-container").css({
      width: `calc(100vw - ${sidebarWidth}px)`,
      height: `calc(100vh - ${headerHeight}px)`
    });
  }
  resizeMap();
  $(window).resize(resizeMap); // Handle window resize
  $(".sidebar-toggle").click(function() {
    setTimeout(resizeMap, 300); // Wait for transition
  });
});
