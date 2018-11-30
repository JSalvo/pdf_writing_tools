require 'PdfWritingToolsActions'

module PdfWritingToolsProcess
  @process_xml_tag_table =
    {
      'text' => method(:process_xml_text),
      'b' => method(:process_xml_tag_b),
      'i' => method(:process_xml_tag_i),
      'ul' => method(:process_xml_tag_ul),
      'li' => method(:process_xml_tag_li),
      'p' => method(:process_xml_tag_p)
    }

  # Dato un oggetto rappresentante il tag b html, processa ricorsivamente i suoi
  # figli cosi' da ottenere le action da applicare per la creazione del pdf
  def self.process_xml_tag_b(xml_obj, properties)
    actions_list = []
    xml_obj.children.each do |child|
      actions_list += process_xml_obj(child, properties + [:bold])
    end
    actions_list
  end

  # Dato un oggetto rappresentante il tag i html, processa ricorsivamente i suoi
  # figli cosi' da ottenere le action da applicare per la creazione del pdf
  def self.process_xml_tag_i(xml_obj, properties)
    actions_list = []
    xml_obj.children.each do |child|
      actions_list += process_xml_obj(child, properties + [:italic])
    end
    actions_list
  end

  # Produce la "action" che permette di disegnare nel pdf, il testo con le
  # proprieta' specificate in proprerties
  def self.process_xml_text(xml_obj, properties)
    data = { text: xml_obj.text + ' ', styles: properties }
    [{ action_name: :draw_formatted_text, data: [data] }]
  end

  # Produce le "actions" che permettono di disegnare nel PDF, la lista contenuta
  # nel tag ul
  def self.process_xml_tag_ul(xml_obj, properties)
    actions_list = []
    xml_obj.children.each do |child|
      actions_list += process_xml_obj(child, properties)
    end
    actions_list
  end

  # Produce le "actions" che permettono di disengare nel PDF, l'elemento della
  # lista indicato da li
  def self.process_xml_tag_li(xml_obj, _properties)
    actions_list = []
    xml_obj.children.each do |child|
      actions_list += process_xml_obj(child, [])
    end
    PdfWritingToolsActions.new_line_action + PdfWritingToolsActions.bullet_action + PdfWritingToolsActions.indent_action(4) + actions_list
  end

  # Produce le "actions" che permettono di disegnare nel PDF, il contenuto
  # del tag p
  def self.process_xml_tag_p(xml_obj, properties)
    actions_list = []
    xml_obj.children.each do |child|
      actions_list += process_xml_obj(child, properties)
    end
    PdfWritingToolsActions.new_line_action + actions_list
  end

  # Produce le actions necessarie per disegnare nel PDF un determinato
  # "tag"
  def self.process_xml_obj(xml_obj, properties)
    case xml_obj.name
    when 'text', 'b', 'i', 'ul', 'li', 'p'
      @process_xml_tag_table[xml_obj.name].call(xml_obj, properties)
    when 'br'
        PdfWritingToolsActions.new_line_action
    else
      [] # Non previsto
    end
  end
end
