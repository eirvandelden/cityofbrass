module.exports = [
  {
    rules: {
      "arrow-parens": "off",
      "generator-star-spacing": "off",
      "no-debugger": process.env.NODE_ENV === "production" ? "error" : "off",
      "no-unexpected-multiline": "off"
    }
  }
];
