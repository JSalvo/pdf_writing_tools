require 'pdf_writing_tools_actions'

module PdfWritingTools
  # Disegna nel pdf (prawn), il testo rappresentato da xml_object
  def self.draw_xml_object(pdf, xml_object)
    # Ottengo una lista di azioni, ciascuna delle quali, quando eseguita,
    # permette di disegnare una parte del documento xml all'interno del pdf
    actions_list = PdfWritingToolsActions.get_actions_list(xml_object)

    # "Eseguo" le azioni contenute nella lista
    PdfWritingToolsActions.execute_actions(pdf, actions_list, nil, [])
  end
end
