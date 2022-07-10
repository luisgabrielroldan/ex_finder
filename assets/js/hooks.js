function setupTreeToggle() {
    const treeToggle = document.body.querySelector('#btn-tree-toggle');
    if (treeToggle) {
        treeToggle.addEventListener('click', event => {
            event.preventDefault();
            document.body.classList.toggle('tree-toggled');
        });
    }
}


function trapFocus(element) {
  var focusableEls = element.querySelectorAll('a[href]:not([disabled]), button:not([disabled]), textarea:not([disabled]), input[type="text"]:not([disabled]), input[type="radio"]:not([disabled]), input[type="checkbox"]:not([disabled]), select:not([disabled])');
  var firstFocusableEl = focusableEls[0];
  var lastFocusableEl = focusableEls[focusableEls.length - 1];
  var KEYCODE_TAB = 9;

  element.addEventListener('keydown', function(e) {
    var isTabPressed = (e.key === 'Tab' || e.keyCode === KEYCODE_TAB);

    if (!isTabPressed) {
      return;
    }

    if ( e.shiftKey ) /* shift + tab */ {
      if (document.activeElement === firstFocusableEl) {
        lastFocusableEl.focus();
          e.preventDefault();
        }
      } else /* tab */ {
      if (document.activeElement === lastFocusableEl) {
        firstFocusableEl.focus();
          e.preventDefault();
        }
      }
  });
}

let Hooks = {}

Hooks.TreeToggle = {
  mounted() {
    setupTreeToggle();
  },
  updated() {
    setupTreeToggle();
  }
}

Hooks.Modal = {
  mounted() {
    trapFocus(this.el);
  },
  destroyed() {
    trapFocus(document);
  }
}

export default Hooks;
