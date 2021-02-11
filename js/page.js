let pages = [window.location.pathname];
let animationLength = 50;

let query = "body > div";

function stackNote(href, level) {
  level = Number(level) || pages.length;
  href = URI(href);
  uri = URI(window.location);
  stacks = [];
  if (uri.hasQuery("stackedNotes")) {
    stacks = uri.query(true).stackedNotes;
    if (!Array.isArray(stacks)) {
      stacks = [stacks];
    }
    stacks = stacks.slice(0, level - 1);
  }
  stacks.push(href.path());
  uri.setQuery("stackedNotes", stacks);

  old_stacks = stacks.slice(0, level - 1);
  state = { stacks: old_stacks, level: level };
  window.history.pushState(state, "", uri.href());
}

function unstackNotes(level) {
    console.log("Unstack level", level);
  let container = document.querySelectorAll(query);
  let children = Array.prototype.slice.call(container);

  for (let i = level; i < pages.length; i++) {
      children[i].remove();
  }
  pages = pages.slice(0, level);
}

function fetchNote(href, level, animate = false) {
  level = Number(level) || pages.length;

  const request = new Request(href);
  fetch(request)
    .then((response) => response.text())
    .then((text) => {
      unstackNotes(level);
      let container = document.querySelector(query);
      let fragment = document.createElement("template");
      fragment.innerHTML = text;
      let element = fragment.content.querySelector("div#content");
      element.id=null;
      document.body.appendChild(element);
      pages.push(href);

      setTimeout(
        function (element, level) {
          element.dataset.level = level + 1;
          initializePreviews(element, level + 1);
          element.scrollIntoView();
          if (animate) {
            element.animate([{ opacity: 0 }, { opacity: 1 }], animationLength);
          }
          if (window.MathJax) {
            window.MathJax.typeset();
          }
        }.bind(null, element, level),
        10
      );

    });
}

function initializePreviews(page, level) {
  level = level || pages.length;

  links = Array.prototype.slice.call(page.querySelectorAll("a:not(.rooter)"));

  links.forEach(async function (element) {
    var rawHref = element.getAttribute("href");
    element.dataset.level = level;

    if (
      rawHref &&
      !(
        rawHref.indexOf("http://") === 0 ||
        rawHref.indexOf("https://") === 0 ||
        rawHref.indexOf("#") === 0 ||
        rawHref.includes(".pdf") ||
        rawHref.includes(".svg")
      )
    ) {
        var prefetchLink = element.href;
        async function myFetch() {
            let response = await fetch(prefetchLink);
            let fragment = document.createElement("template");
            fragment.innerHTML = await response.text();
            let ct = await response.headers.get("content-type");
            if (ct.includes("text/html")) {
                //createPreview(element, fragment.content.querySelector('.page').outerHTML, {
                //placement:
                //    window.innerWidth > switchDirectionWindowWidth
                //    ? "right"
                //    : "top",
                //});

                element.addEventListener("click", function (e) {
                if (!e.ctrlKey && !e.metaKey) {
                    e.preventDefault();
                    stackNote(element.href, this.dataset.level);
                    fetchNote(element.href, this.dataset.level, (animate = true));
                }
                });
            };
        }
        return myFetch();
    }
  });
}

window.addEventListener("popstate", function (event) {
  // TODO: check state and pop pages if possible, rather than reloading.
  window.location = window.location; // this reloads the page.
});

window.onload = function () {
  //loadNetworkNodes();
  initializePreviews(document.querySelector(query));

  uri = URI(window.location);
  if (uri.hasQuery("stackedNotes")) {
    stacks = uri.query(true).stackedNotes;
    if (!Array.isArray(stacks)) {
      stacks = [stacks];
    }
    for (let i = 1; i <= stacks.length; i++) {
      fetchNote(stacks[i - 1], i);
    }
  }
};
