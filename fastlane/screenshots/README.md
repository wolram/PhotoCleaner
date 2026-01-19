# 📸 Screenshots para App Store

## Requisitos

- **Resolução:** 2560x1600px (Retina Display)
- **Formato:** PNG ou JPG
- **Quantidade:** Mínimo 3, recomendado 5

## Como Tirar Screenshots

1. Rode o app no Xcode (⌘R)
2. Navegue para a tela desejada
3. Pressione ⇧⌘5 (Shift+Command+5) ou ⇧⌘4 (Shift+Command+4)
4. Capture a tela
5. Salve aqui neste diretório

## Sugestões de Screenshots

1. **Tela Principal** - Interface com sidebar e overview
2. **Resultados da Análise** - Stats mostrando espaço recuperável
3. **Duplicados** - Grid de fotos duplicadas agrupadas
4. **Modo Peneira** - Comparação lado a lado
5. **Estatísticas** - Gráficos e visualizações

## Nomenclatura Recomendada

```
1_main_interface.png
2_scan_results.png
3_duplicates_view.png
4_sieve_mode.png
5_statistics.png
```

## Verificar Resolução

```bash
# Ver tamanho de uma imagem
sips -g pixelWidth -g pixelHeight screenshot.png
```

## Redimensionar (se necessário)

```bash
# Redimensionar para 2560x1600
sips -z 1600 2560 screenshot.png --out screenshot_resized.png
```

---

**Depois de adicionar os screenshots, rode:**

```bash
fastlane release
```
