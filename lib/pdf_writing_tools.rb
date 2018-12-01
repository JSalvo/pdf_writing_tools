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
end
