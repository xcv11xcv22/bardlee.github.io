document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('div.highlighter-rouge').forEach((codeBlock) => {
    const button = document.createElement('button');
    button.className = 'copy-code-button';
    button.type = 'button';
    button.innerText = 'Copy';
  
    button.addEventListener('click', () => {
      const code = codeBlock.querySelector('pre code');
      navigator.clipboard.writeText(code.innerText).then(() => {
        button.innerText = 'Copied!';
        setTimeout(() => {
          button.innerText = 'Copy';
        }, 2000);
      });
    });
  
    codeBlock.appendChild(button);
  });
});
