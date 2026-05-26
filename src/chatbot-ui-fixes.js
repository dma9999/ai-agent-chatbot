// Chatbot UI Fixes and Enhancements
// Apply custom styling and behavior to CX Agent Studio widget

(function() {
  window.ChatbotUIFixes = {
    init: function() {
      console.log("[Chatbot UI] Initializing fixes...");
      
      // Wait for widget to load
      const checkWidget = setInterval(() => {
        const widget = document.querySelector("[data-cx-agent-widget]");
        if (widget) {
          clearInterval(checkWidget);
          this.applyFixes();
        }
      }, 100);
    },

    applyFixes: function() {
      // Fix close button visibility
      this.fixCloseButton();
      
      // Apply custom styling
      this.applyCustomStyling();
      
      // Enhance accessibility
      this.enhanceAccessibility();
    },

    fixCloseButton: function() {
      const closeBtn = document.querySelector("[data-cx-agent-close-button]");
      if (closeBtn) {
        closeBtn.style.display = "block";
        closeBtn.style.opacity = "1";
        closeBtn.setAttribute("role", "button");
        closeBtn.setAttribute("aria-label", "Close chatbot");
        console.log("[Chatbot UI] ✓ Close button fixed");
      }
    },

    applyCustomStyling: function() {
      const style = document.createElement("style");
      style.textContent = `
        [data-cx-agent-widget] {
          font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        }
        
        [data-cx-agent-widget] .message {
          border-radius: 8px;
          padding: 12px 16px;
        }
        
        [data-cx-agent-widget] .user-message {
          background-color: #3b82f6;
          color: white;
        }
        
        [data-cx-agent-widget] .bot-message {
          background-color: #f3f4f6;
          color: #1f2937;
        }
      `;
      document.head.appendChild(style);
      console.log("[Chatbot UI] ✓ Custom styling applied");
    },

    enhanceAccessibility: function() {
      const widget = document.querySelector("[data-cx-agent-widget]");
      if (widget) {
        widget.setAttribute("role", "region");
        widget.setAttribute("aria-label", "Chatbot assistant");
        widget.setAttribute("aria-live", "polite");
        console.log("[Chatbot UI] ✓ Accessibility enhanced");
      }
    }
  };

  // Initialize when DOM is ready
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", () => window.ChatbotUIFixes.init());
  } else {
    window.ChatbotUIFixes.init();
  }
})();
