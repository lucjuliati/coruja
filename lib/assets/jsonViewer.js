function createJsonViewer(container, jsonData) {
  function createTreeElement(key, value) {
    const wrapper = document.createElement("div");
    wrapper.classList.add("json-item");

    const keyElement = document.createElement("span");
    keyElement.textContent = key ? `"${key}": ` : "";
    keyElement.classList.add("json-key");

    if (typeof value === "object" && value !== null) {
      const toggle = document.createElement("span");
      toggle.textContent = "▶";
      toggle.classList.add("json-toggle");

      const nestedContainer = document.createElement("div");
      nestedContainer.classList.add("json-nested");
      nestedContainer.style.display = "none";

      if (Array.isArray(value)) {
        value.forEach((item, index) => {
          nestedContainer.appendChild(createTreeElement(`[${index}]`, item));
        });
      } else {
        Object.entries(value).forEach(([nestedKey, nestedValue]) => {
          nestedContainer.appendChild(createTreeElement(nestedKey, nestedValue));
        });
      }

      toggle.addEventListener("click", () => {
        const isVisible = nestedContainer.style.display === "block";
        nestedContainer.style.display = isVisible ? "none" : "block";
        toggle.textContent = isVisible ? "▶" : "▼";
      });

      wrapper.appendChild(toggle);
      wrapper.appendChild(keyElement);
      wrapper.appendChild(nestedContainer);
    } else {
      const valueElement = document.createElement("span");

      if (typeof value === "string") {
        valueElement.textContent = `"${value}"`;
      } else if (typeof value === "boolean") {
        valueElement.innerHTML = `<span style='color:rgb(221, 113, 194);'>${value}</span>`;
      } else {
        valueElement.innerHTML = `<span style='color:rgb(101, 192, 121);'>${value}</span>`;
      }

      valueElement.classList.add("json-value");
      wrapper.appendChild(keyElement);
      wrapper.appendChild(valueElement);
    }

    return wrapper;
  }

  container.innerHTML = "";
  const root = document.createElement("div");
  root.classList.add("json-viewer");

  if (typeof jsonData === "object" && !Array.isArray(jsonData)) {
    Object.entries(jsonData).forEach(([key, value]) => {
      root.appendChild(createTreeElement(key, value));
    });
  } else if (Array.isArray(jsonData)) {
    jsonData.forEach((item, index) => {
      root.appendChild(createTreeElement(`[${index}]`, item));
    });
  }

  container.appendChild(root);
}

const container = document.getElementById("json-container");
createJsonViewer(container, jsonData);

document.head.insertAdjacentHTML("beforeend", `
<style>
    html { scroll-behavior: smooth; }
    body { background-color: #202023; }
    .json-viewer { font-family: monospace; }
    .json-item { margin-left: 4px; }
    .json-key { color:rgb(117, 188, 206); }
    .json-value { color:rgb(201, 131, 104); }
    .json-nested { margin-left: 12px; }
    .json-toggle { 
        cursor: pointer; margin-right: 5px; color: #777777; user-select:none; position: relative;
        &:hover { filter: brightness(1.3); }
    }
    .json-toggle::after { content:''; width: 80px; height: 16px; position: absolute; left: 0; top: 0}
</style>
`);
