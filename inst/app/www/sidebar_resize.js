$(document).on("shiny:connected", function() {

  var MIN_WIDTH = 300;
  var MAX_WIDTH = 600;
  var PADDING   = 40; // extra breathing room

  function getSidebarContentWidth() {
    var maxW = 0;

    // Measure the widest visible element inside the sidebar
    $(".main-sidebar .sidebar *:visible").each(function() {
      var el = $(this);
      // scrollWidth captures content that overflows
      var sw = this.scrollWidth || 0;
      // Also check explicit rendered width
      var ow = el.outerWidth(true) || 0;
      var w  = Math.max(sw, ow);
      if (w > maxW) maxW = w;
    });

    return maxW;
  }

  function resizeSidebar() {
    if ($("body").hasClass("sidebar-collapse")) {
      applySidebarWidth(0);
      return;
    }

    // Let content render at natural width before measuring
    // Temporarily remove width constraints so we can measure true content width
    $(".main-sidebar").css("width", "auto");
    $(".main-sidebar .sidebar").css("width", "auto");

    var contentWidth = getSidebarContentWidth() + PADDING;
    var newWidth = Math.max(MIN_WIDTH, Math.min(MAX_WIDTH, contentWidth));

    // Re-apply the calculated width
    applySidebarWidth(newWidth);
  }

  function applySidebarWidth(w) {
    var headerHeight = $(".main-header").outerHeight() || 50;

    if (w === 0) {
      // Collapsed state
      $(".main-sidebar").css("width", "0px");
      $(".main-header .logo").css("width", "0px");
      $(".main-header .navbar").css("margin-left", "0px");
      $(".content-wrapper").css("margin-left", "0px");
      $(".map-container").css({
        width: "100vw",
        height: "calc(100vh - " + headerHeight + "px)"
      });
      return;
    }

    $(".main-sidebar").css("width", w + "px");
    $(".main-sidebar .sidebar").css("width", w + "px");
    $(".main-header .logo").css("width", w + "px");
    $(".main-header .navbar").css("margin-left", w + "px");
    $(".content-wrapper").css("margin-left", w + "px");

    $(".map-container").css({
      width: "calc(100vw - " + w + "px)",
      height: "calc(100vh - " + headerHeight + "px)"
    });
  }

  // --- Triggers ---

  // Initial sizing
  resizeSidebar();

  // Window resize
  $(window).resize(resizeSidebar);

  // Sidebar collapse toggle
  $(".sidebar-toggle").click(function() {
    setTimeout(resizeSidebar, 350);
  });

  // Re-measure whenever shinyTree renders or updates nodes
  // (jstree fires events we can hook into)
  $(document).on("ready.jstree open_node.jstree search.jstree", function() {
    setTimeout(resizeSidebar, 200);
  });

  // Re-measure when tabs change (your sidebar has tabsetPanel)
  $(document).on("shown.bs.tab", function() {
    setTimeout(resizeSidebar, 200);
  });

  // Re-measure when Shiny recalculates outputs (catches dynamic UI updates)
  $(document).on("shiny:value", function() {
    setTimeout(resizeSidebar, 300);
  });

});