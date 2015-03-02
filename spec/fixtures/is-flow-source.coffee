module.exports = [
  {
    text: """
          /* @flow */

          var n = 0;
          """
    desc: "simple top comment"
    match: true
  }
  {
    text: """
          var n = 0;

          /* @flow */
          """
    desc: "not top comment"
    match: false
  }
  {
    text: """


          /**
           * Bla bla bla
           *
           * LICENSE LICENSE LICENSE
           *
           * @flow
           */

          var n = 0;
          """
    desc: "Long comment and blank lines"
    match: true
  }
  {
    text: """


          /**
           * Bla bla bla
           *
           * LICENSE LICENSE LICENSE
           *
           */

          var n = 0;
          """
    desc: "Long comment and blank lines no @flow"
    match: false
  }
  {
    text: """
          /**
           * Bla bla bla
           */

          /* @flow */

          var n = 0;
          """
    desc: "@flow not in first comment"
    match: false
  }
]
