import re

with open('MENSAJE_EQUIPO.md', 'r') as f:
    text = f.read()
    
# fix trailing space
text = re.sub(r' \n', '\n', text)

# fix heading 3 to heading 2 and remove trailing punctuation
text = text.replace('### Instrucciones obligatorias para sincronizar sus máquinas locales:', '## Instrucciones obligatorias para sincronizar sus máquinas locales')

# ensure blank lines before and after fenced code blocks
text = text.replace(':\n   ```', ':\n\n   ```')
text = text.replace('```\n\n2.', '```\n\n\n2.')
text = text.replace('```\n\n3.', '```\n\n\n3.')
text = text.replace('```\n\n4.', '```\n\n\n4.')
text = text.replace('```\n\n>', '```\n\n\n>')

with open('MENSAJE_EQUIPO.md', 'w') as f:
    f.write(text)

try:
    path2 = '/home/jhonataningesis/.gemini/antigravity-ide/brain/58a7d712-ebe4-41b0-a75a-2442bbb409a7/implementation_plan.md'
    with open(path2, 'r') as f:
        text2 = f.read()
    
    # MD022/032: blanks around headings and lists
    text2 = re.sub(r'([^\n])\n(#+ .*)', r'\1\n\n\2', text2)
    text2 = re.sub(r'(#+ .*)\n([^\n])', r'\1\n\n\2', text2)
    
    with open(path2, 'w') as f:
        f.write(text2)
except:
    pass
