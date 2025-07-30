module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/foundation_web/**/*.*ex"
  ],
  theme: {
    extend: {
      spacing: {
        '1': '4px',
        '2': '8px',
        '3': '12px',
        '4': '16px',
        '5': '20px',
        '6': '24px',
        '8': '32px',
        '10': '40px',
        '12': '48px',
        '16': '64px',
        '20': '80px',
        '24': '96px'
      },
      gridTemplateColumns: {
        '12': 'repeat(12, minmax(0, 1fr))'
      }
    }
  },
  plugins: [
    require("@tailwindcss/container-queries")
  ]
}