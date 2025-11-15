/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: "class",
  content: [
    "./app/views/**/*.erb",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/assets/**/*.js",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          50:  "#eef5ff",
          100: "#d8e6ff",
          200: "#b3caff",
          300: "#83a6ff",
          400: "#4d7dff",
          500: "#2563eb",   // primary blue (logo/button)
          600: "#1d4ed8",
          700: "#1e40af",
          800: "#1e3a8a",
          900: "#172554"
        }
      },
      boxShadow: {
        card: "0 2px 12px rgba(0,0,0,.25)"
      }
    }
  },
  plugins: [],
};
