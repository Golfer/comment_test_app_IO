import js from "@eslint/js"
import globals from "globals"

export default [
  {
    ignores: [
      "app/assets/builds/**",
      "node_modules/**"
    ]
  },
  js.configs.recommended,
  {
    files: ["app/javascript/**/*.js"],
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
      globals: {
        ...globals.browser,
        ...globals.node
      }
    },
    rules: {
      "no-console": "warn"
    }
  }
]
