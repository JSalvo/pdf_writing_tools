require 'pdf_writing_tools_actions'
require 'pdf_writing_tools_process'

module PdfWritingTools
  # Disegna nel pdf (prawn), il testo rappresentato da xml_object
  # La proprietà .name di xml_object, deve essere uguale a 'nothtml', altrimenti,
  # non viene prodotto nulla.
  # Al momento, vengono processati i seguenti tag:
  # p   (paragrafo)
  # ul  (lista non ordinata)
  # li  (elemento di lista non ordinata)
  # b   (grassetto)
  # i   (italico)
  # Altri tag non in elenco, vengono ignorati o causano errore
 
 
  # L'oggetto xml, viene letto ricorsivamente. Si crea una lista, contenente
  # dei dizionari. Ciascun dizionario contiene:
  # Il nome di un'azione: :action_name 
  # Una lista "data", contenente un dizionario con al suo interno le specifiche
  # da dare a prawn, per "disegnare" del testo o per disegnare un'immagine
  #
  # Le p
 
  def self.draw_xml_object(pdf, xml_object)
    # Ottengo una lista di azioni, ciascuna delle quali, quando eseguita,
    # permette di disegnare una parte del documento xml all'interno del pdf
    actions_list = get_actions_list(xml_object)

    # "Eseguo" le azioni contenute nella lista
    PdfWritingToolsActions.execute_actions(pdf, actions_list, nil, [])
  end

  # Produce le actions necessarie per disegnare nel PDF l'intero documento
  # XML
  def self.get_actions_list(xml_object)
    actions_list = []
    if xml_object.name == 'nothtml'
      xml_object.children.each do |child|
        actions_list += PdfWritingToolsProcess.process_xml_obj(child, [])
      end
    end
    actions_list
  end


    ######## Disegna una cella di dimensioni fissate, nella data posizione. ######
  #   E' Possibile indicare il colore del bordo, dello sfondo, del font e della
  # relativa dimensione (oltre a tutta un'altra serie di parametri (opts), vedere prima
  # parte della funzione)
  #   La cella, viene disegnata "globalmente", rispetto al pdf, ossia NON relativamente
  # ad altri contenitori.
  #   x e y, indicano rispettivamente le coordinate x e y del vertice in alto a
  # sinistra del box.
  #   Il vertice è relativo al margine superiore del pdf, contrariamente a quanto
  # accade quando si utilizzano le primitive prawn (dove il margine di riferimento è 
  # quello basso della pagina).
  #   Bisogna pertanto prestare attenzione quando si mischiano primitive prawn
  # con queste funzioni.
  def self.draw_cell_fixed_height(pdf, x, y, w, h, t, opts={})
    font_size = opts[:font_size] || 10
    style = opts[:style] || :normal
    align = opts[:align] || :left
    valign = opts[:valign] || :top
    font_color = opts[:font_color] || '000000'
    border_color = opts[:border_color] || '000000'
    background_color = opts[:background_color] || 'FFFFFF'
    left_padding = opts[:left_padding] || 5
    right_padding = opts[:right_padding] || 5
    top_padding = opts[:top_padding] || 5
    bottom_padding = opts[:bottom_padding] || 5
    pdf_height = opts[:pdf_height] || 297.mm
    pdf_width = opts[:pdf_width] || 21.cm

    result = ''

    pdf.canvas do
      pdf.line_width = 0.5

      # Colore di sfondo della cella
      pdf.fill_color(background_color)

      # Disegna lo sfondo della cella
      pdf.fill_rectangle([x, pdf_height - y], w, h)

      pdf.stroke_color border_color
      pdf.stroke_rectangle([x, pdf_height - y], w, h)

      # Colore del testo nella cella
      pdf.fill_color(font_color)
      # Disegno il testo contenuto nella cella
      result = pdf.text_box(
        t,
        at: [x + left_padding, pdf_height - y - top_padding],
        width: w - left_padding - right_padding,
        height: h - top_padding - bottom_padding,
        size: font_size,
        style: style,
        align: align,
        valign: valign
      )
    end

    result
  end
end
