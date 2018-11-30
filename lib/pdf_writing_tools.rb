module PdfWritingTools
  # Questa action contiene istruzioni per disegnare un "a capo" nel PDF
  def self.new_line_action
    [{ action_name: :draw_formatted_text, data: [{ text: "\n" }] }]
  end

  # Questa action, contiene istruzioni per disegnare nel pdf
  # indent_spaces spazi, in modo da creare degli extra spazi,
  # utili per i rientri
  def self.indent_action(indent_spaces = 4)
    [{
      action_name: :draw_formatted_text,
      data: [
        { text: Prawn::Text::NBSP * indent_spaces,
          styles: %i[bold white] }
      ]
    }]
  end

  # Questa action, contiene istruzioni per disegnare un "bullet", ossia
  # un oggetto grafico, tipo un segno di spunta accanto all'elemnto di
  # una lista
  def self.bullet_action
    [
      {
        action_name: :draw_image, data:
        {
          url: 'public/bullet.png' # Pallino
        }
      }
    ]
  end

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
    new_line_action + bullet_action + indent_action(4) + actions_list
  end

  # Produce le "actions" che permettono di disegnare nel PDF, il contenuto
  # del tag p
  def self.process_xml_tag_p(xml_obj, properties)
    actions_list = []
    xml_obj.children.each do |child|
      actions_list += process_xml_obj(child, properties)
    end
    new_line_action + actions_list
  end

  # Produce le actions necessarie per disegnare nel PDF un determinato
  # "tag"
  def self.process_xml_obj(xml_obj, properties)
    case xml_obj.name
    when 'text', 'b', 'i', 'ul', 'li', 'p'
      @process_xml_tag_table[xml_obj.name].call(xml_obj, properties)
    when 'br'
      new_line_action
    else
      [] # Non previsto
    end
  end

  # Produce le actions necessarie per disegnare nel PDF l'intero documento
  # XML
  def self.get_actions_list(xml_object)
    actions_list = []
    if xml_object.name == 'nothtml'
      xml_object.children.each do |child|
        actions_list += process_xml_obj(child, [])
      end
    end
    actions_list
  end

  # Disegna nel pdf (prawn), il testo rappresentato da xml_object
  def self.draw_xml_object(pdf, xml_object)
    # Ottengo una lista di azioni, ciascuna delle quali, quando eseguita,
    # permette di disegnare una parte del documento xml all'interno del pdf
    actions_list = get_actions_list(xml_object)

    # "Eseguo" le azioni contenute nella lista
    execute_actions(pdf, actions_list, nil, [])
  end

  # Esegue last_action, oppure concatena i dati di action e di last_action
  def self.text_action(pdf, action, last_action_name, data)
    if last_action_name.nil?
      data = action[:data]
    elsif last_action_name == :draw_formatted_text
      data += action[:data]
    else
      execute_action(pdf, last_action_name, data)
      data = action[:data]
    end
    [:draw_formatted_text, data]
  end

  # Mentre la "scrittura/disegno" del testo, puo' essere "concatenato", nel caso
  # delle immagini no. Una action sulla immagine, pertanto interrompe la
  # possibilita' di concatenare i data delle action di testo. Pertanto, eseguo
  # in ogni caso last_action, a meno che last_action non sia nil (ossia action
  # e' la prima azione della lista)
  def self.img_action(pdf, action, last_action_name, data)
    execute_action(pdf, last_action_name, data) unless last_action_name.nil?
    [:draw_image, action[:data]]
  end

  # Esegue un azione, andando a scrivere del testo nel PDF oppure un'immagine
  def self.execute_action(pdf, action_name, data)
    if action_name == :draw_formatted_text
      pdf.formatted_text(data, align: :left)
    elsif action_name == :draw_image
      current_cursor_position = pdf.cursor
      pdf.move_cursor_to(current_cursor_position - 3)
      pdf.image(data[:url], height: 6, width: 6)
      pdf.move_cursor_to(current_cursor_position)
    end
  end

  # Esegue le azioni, andando a concatenare quelle "contigue" nella lista,
  # che riguardano la scrittura di testo
  def self.execute_actions(pdf, actions, last_actn_name, data)
    actions.each do |action|
      if action[:action_name] == :draw_formatted_text
        last_actn_name, data = text_action(pdf, action, last_actn_name, data)
      elsif action[:action_name] == :draw_image
        last_actn_name, data = img_action(pdf, action, last_actn_name, data)
      end
    end
    execute_action(pdf, last_actn_name, data)
  end

  @process_xml_tag_table =
    {
      'text' => method(:process_xml_text),
      'b' => method(:process_xml_tag_b),
      'i' => method(:process_xml_tag_i),
      'ul' => method(:process_xml_tag_ul),
      'li' => method(:process_xml_tag_li),
      'p' => method(:process_xml_tag_p)
    }


end
