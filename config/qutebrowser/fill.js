// The payload is inserted only into a private runtime file, never a command.
(() => {
  const login = /*__LOGIN__*/;
  const fail = (reason) => { window.alert(`Bitwarden: ${reason}`); };
  try {
    if (window.location.href !== login.url) {
      fail("Page changed; nothing filled. Invoke the binding again.");
      return;
    }
    const isEditable = (element) => element instanceof HTMLInputElement &&
      !element.disabled && !element.readOnly && element.getClientRects().length > 0 &&
      ["text", "email", "password", "tel", "number", "search", "url"].includes(element.type);
    const setValue = (element, value) => {
      Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, "value").set.call(element, value);
      element.dispatchEvent(new Event("input", { bubbles: true }));
      element.dispatchEvent(new Event("change", { bubbles: true }));
    };
    const focused = document.activeElement;
    if (!isEditable(focused)) {
      fail("Focus a login field first.");
      return;
    }
    if (login.mode !== "login") {
      if (login.mode === "password" && focused.type !== "password") {
        fail("Focus a password field first.");
        return;
      }
      setValue(focused, login.value);
      return;
    }
    const fields = [...(focused.form || document).querySelectorAll("input")].filter(isEditable);
    const passwords = fields.filter((field) => field.type === "password");
    if (passwords.length !== 1) {
      fail("Use username-only or password-only for this form.");
      return;
    }
    const password = passwords[0];
    const preceding = fields.slice(0, fields.indexOf(password)).filter((field) =>
      ["text", "email", "tel"].includes(field.type));
    const username = focused.type === "password" ? preceding.at(-1) : focused;
    if (!username || !preceding.includes(username)) {
      fail("Focus the username field, or use the separate field bindings.");
      return;
    }
    setValue(username, login.value.username);
    setValue(password, login.value.password);
    password.focus();
  } catch {
    fail("Could not fill this form.");
  }
})();
